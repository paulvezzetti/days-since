//
//  AddTaskTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import CoreData
import UIKit
import UserNotifications

class AddActivityTableViewController: UITableViewController {


    // MARK: - Outlets
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var startDateTextField: UITextField!
    @IBOutlet private var intervalLabel: UILabel!
    @IBOutlet weak var activeRangeLabel: UILabel!
    
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var enableRemindersSwitch: UISwitch!
    @IBOutlet private var remindTextField: UITextField!
    @IBOutlet private var snoozeSwitch: UISwitch!
    @IBOutlet private var snoozeTextField: UITextField!
    @IBOutlet private var reminderTimeTextField: UITextField!
    
    // MARK: - Picker input views
    private var startDatePickerView: TimePickerView?
    private var reminderTimePicker: TimePickerView?
    
    // MARK: - Public properties
    var editActivity: ActivityMO? = nil
    var dataManager: DataModelManager? = nil
    
    // MARK: - Private properties
    private var managedObjectContext: NSManagedObjectContext? = nil
    
    private var tempActivity: ActivityMO? = nil

    private var reminderTimeOfDay: Date = Calendar.current.startOfDay(for: Date())

    private lazy var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        return formatter
    }()
    
    private lazy var timeFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
        
    // Mark: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try initializeManagedObjectContext()
        } catch {
            
        }
        
        guard let context = managedObjectContext else {
            // TODO Show the user an error
            return
        }
        
        initReminderTimeInputView()
        initStartDateInputView()
        
        titleField.delegate = self
        snoozeTextField.delegate = self
        
        titleField.inputAssistantItem.leadingBarButtonGroups = []
        titleField.inputAssistantItem.trailingBarButtonGroups = []
        
        // Copy the settings to the temp activity
        if let activityToEdit = editActivity {
            // If we are editing an existing activity, clone it with just the first event history
            tempActivity = activityToEdit.clone(context: context, eventCloneOptions: .First)
            
            // Initialize the reminder time of day from activity
            reminderTimeOfDay = Date(timeInterval: activityToEdit.reminder?.timeOfDay ?? 0, since: Calendar.current.startOfDay(for: Date()))
            
            // Fill in the initial values
            configureViewForActivity()

        } else {
            // Otherwise, initialize a new one
            let newActivity = ActivityMO(context: context)
            newActivity.id = UUID()
            newActivity.reminder = ReminderMO(context: context)
            newActivity.interval = UnlimitedIntervalMO(context: context)

            let firstEvent = EventMO(context: context)
            firstEvent.timestamp = Date.normalize(date: Date())
            newActivity.addToHistory(firstEvent)

            self.tempActivity = newActivity
            
            // If we are granted access for notifications, then enable reminders by default
            let notificationCenter = UNUserNotificationCenter.current()
            
            notificationCenter.getNotificationSettings { (settings) in
                // Do not enable reminders if not authorized.
                guard settings.authorizationStatus == .authorized else {return}
                
                if settings.alertSetting == .enabled {
                    // Since the default interval is Unlimited there is no reason to turn on reminders by default
                    self.tempActivity?.reminder?.enabled = false
                    self.tempActivity?.reminder?.allowSnooze = false
                    DispatchQueue.main.async {
                        self.configureViewForActivity()
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureViewForActivity()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "chooseWhenSegue" {
            let controller = segue.destination as! ChooseIntervalTableViewController
            controller.activity = tempActivity
            return
        }

        if segue.identifier == "chooseDateRangeSeque" {
            let controller = segue.destination as! ChooseActiveRangeTableViewController
            controller.activity = tempActivity
            return
        }

        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }

        guard let activity = tempActivity else {
            return
        }
        // Update activity from UI. Some items like the interval, start date, and active range are updated
        // immediately when the user makes the selection.
        activity.name = titleField.text!
        let enableReminders = enableRemindersSwitch.isOn
        activity.reminder?.enabled = enableReminders
        let remindDaysBefore = UITextFieldUtility.getAsInt(textField: remindTextField, defaultValue: ReminderMO.REMIND_DAYS_BEFORE_DEFAULT, minimumValue: ReminderMO.REMIND_DAYS_BEFORE_DEFAULT)
        activity.reminder?.daysBefore = Int16(remindDaysBefore)

        // Calculate the time of day for reminders based on the number of seconds since midnight.
        let midnight = Calendar.current.startOfDay(for: reminderTimeOfDay)
        // timeOfDay is seconds since midnight. The reminderTimeOfDay is a complete date.
        activity.reminder?.timeOfDay = reminderTimeOfDay.timeIntervalSince(midnight)

        let allowSnooze = enableReminders && snoozeSwitch.isOn
        activity.reminder?.allowSnooze = allowSnooze
        
        let snooze = UITextFieldUtility.getAsInt(textField: snoozeTextField, defaultValue: ReminderMO.SNOOZE_FOR_DAYS_DEFAULT, minimumValue: ReminderMO.SNOOZE_FOR_DAYS_DEFAULT)
        activity.reminder?.snooze = Int16(snooze)
        
        if let activityToUpdate = editActivity {
            updateActivity(source: activity, target: activityToUpdate)
        } else {
            // Save the context
            do {
                try managedObjectContext?.save()
                try dataManager?.saveContext()
            } catch let error as NSError {
                print("Unable to save new activity: \(error)")
            }
        }
    }

    // MARK: - IBActions
    
    @IBAction func enableReminderChanged(_ sender: Any) {
        let enableReminders = enableRemindersSwitch.isOn
        if enableReminders {
            // Check for push permission. This is async. If it fails, we will disable notifications.
            requestPermissionForPushNotifications()
        }
        tempActivity?.reminder?.enabled = enableReminders
        remindTextField.isEnabled = enableReminders
        reminderTimeTextField.isEnabled = enableReminders
        snoozeSwitch.isEnabled = enableReminders
        if !enableReminders {
            snoozeSwitch.isOn = false
            remindTextField.text = String(ReminderMO.REMIND_DAYS_BEFORE_DEFAULT)
        }
        snoozeTextField.isEnabled = snoozeSwitch.isOn
        if !snoozeSwitch.isOn {
            snoozeTextField.text = String(ReminderMO.SNOOZE_FOR_DAYS_DEFAULT)
        }
    }
    
    @IBAction func enableSnoozeChanged(_ sender: Any) {
        snoozeTextField.isEnabled = snoozeSwitch.isOn
    }
    
    
    @IBAction func cancelAdd(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func titleFieldChanged(_ sender: Any) {
        
        let title = titleField.text ?? ""
        saveButton.isEnabled = !title.isEmpty
        navigationItem.title = title
    }
    
}

// MARK: - Private extension
extension AddActivityTableViewController {
    
    private func initReminderTimeInputView() {
        reminderTimePicker = TimePickerView()
        reminderTimePicker?.delegate = self
        reminderTimePicker?.initialDate = reminderTimeOfDay
        reminderTimePicker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        reminderTimeTextField.inputView = reminderTimePicker
        reminderTimeTextField.delegate = self
    }
    
    private func initStartDateInputView() {
        startDatePickerView = TimePickerView()
        startDatePickerView?.delegate = self
        startDatePickerView?.initialDate = Date()
        startDatePickerView?.mode = UIDatePicker.Mode.date
        startDatePickerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        startDateTextField.inputView = startDatePickerView
        startDateTextField.delegate = self

    }
    
    private func initializeManagedObjectContext() throws {
        if self.managedObjectContext == nil {
            self.managedObjectContext = try dataManager?.newChildManagedObjectContext()
        }
    }
    
    private func configureViewForActivity() {
        guard let activity = tempActivity else {
            return
        }
        titleField.text = activity.name
        intervalLabel.text = activity.interval!.toPrettyString()
        startDateTextField.text = dateFormatter.string(from: activity.firstDate)
        
        activeRangeLabel.text = activity.interval?.activeRange != nil ? activity.interval?.activeRange?.toPrettyString() : ActiveRangeMO.getStringForNil()
        
        let title = titleField.text ?? ""
        saveButton.isEnabled = !title.isEmpty
        
        let enableReminder = activity.reminder?.enabled ?? false
        enableRemindersSwitch.isEnabled = !(activity.interval is UnlimitedIntervalMO)
        enableRemindersSwitch.setOn(enableReminder, animated: false)
        remindTextField.isEnabled = enableReminder
        remindTextField.text = String(activity.reminder?.daysBefore ?? Int16(ReminderMO.REMIND_DAYS_BEFORE_DEFAULT))
        reminderTimeTextField.isEnabled = enableReminder        
        reminderTimeTextField.text = timeFormatter.string(from: reminderTimeOfDay)
        
        let enableSnooze = activity.reminder?.allowSnooze ?? false
        snoozeSwitch.setOn(enableSnooze, animated: false)
        snoozeSwitch.isEnabled = enableReminder
        snoozeTextField.isEnabled = enableSnooze
        snoozeTextField.text = String(activity.reminder?.snooze ?? Int16(ReminderMO.SNOOZE_FOR_DAYS_DEFAULT))
        
    }
    
    // Copies values from the source to the target
    private func updateActivity(source: ActivityMO, target:ActivityMO) {
        if source.name != target.name {
            target.name = source.name
        }
        if let sourceInterval = source.interval, let targetInterval = target.interval {
            if !(sourceInterval.isEquivalent(to: targetInterval)) {
                if let parentMoc = managedObjectContext?.parent {
                    target.interval = sourceInterval.clone(context: parentMoc)
                }
            }

        }
        let firstDate = source.firstDate
        if firstDate != target.firstDate {
            target.updateFirstDate(to: Date.normalize(date:firstDate))
        }
        if let sourceReminder = source.reminder, let targetReminder = target.reminder {
            targetReminder.enabled = sourceReminder.enabled
            targetReminder.allowSnooze = sourceReminder.allowSnooze
            targetReminder.daysBefore = sourceReminder.daysBefore
            targetReminder.timeOfDay = sourceReminder.timeOfDay
            targetReminder.snooze = sourceReminder.snooze

        }
    }

    private func onPermissionForPushNotificationDenied() {
        let alert = UIAlertController(title: NSLocalizedString("authorizationRequired.title", value: "Authorization Required", comment: ""), message:
            NSLocalizedString("pushNotificationsDisabled.msg", value: "Push notifications have been disabled for this application. Go to Settings and enable notifications in order to receive reminders.", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("settings.title", value: "Settings", comment: ""), style: UIAlertAction.Style.default) { (alert) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.tempActivity?.reminder?.enabled = false
        self.tempActivity?.reminder?.allowSnooze = false
        
        enableRemindersSwitch.setOn(false, animated: false)
        remindTextField.isEnabled = false
        snoozeSwitch.setOn(false, animated: false)
        
    }

    // TODO: This needs to move to some type of Notification Manager for the app
    private func requestPermissionForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) {
            granted, error in
            print("Permission granted: \(granted)")
            if !granted {
                DispatchQueue.main.async {
                    self.onPermissionForPushNotificationDenied()
                }
            }
        }
    }

}

// MARK: -  UITextFieldDelegate

extension AddActivityTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField === titleField {
            let title = textField.text ?? ""
            saveButton.isEnabled = !title.isEmpty
            navigationItem.title = title
            tempActivity?.name = title
        } else if textField === snoozeTextField {
            let snoozeDays = Int(snoozeTextField.text ?? "")
            if snoozeDays == nil || snoozeDays! < 1 {
                snoozeTextField.text = String(ReminderMO.SNOOZE_FOR_DAYS_DEFAULT)
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === reminderTimeTextField || textField == startDateTextField{
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == reminderTimeTextField {
            reminderTimePicker?.initialDate = reminderTimeOfDay
        } else if textField == startDateTextField {
            startDatePickerView?.initialDate = tempActivity?.firstDate ?? Date()
        }
    }
    
}

// MARK: -  TimePickerViewDelegate

extension AddActivityTableViewController : TimePickerViewDelegate {
    
    func timeValueChange(to date: Date, picker: TimePickerView) {
        if picker == reminderTimePicker {
            guard let reminderTextField = reminderTimeTextField else {
                return;
            }
            reminderTextField.text =  timeFormatter.string(for: date)
            
            reminderTimeOfDay = date
        } else if picker == startDatePickerView {
            if let activity = tempActivity {
                activity.updateFirstDate(to: Date.normalize(date: date))
                startDateTextField.text = dateFormatter.string(from: activity.firstDate)
            }
        }
    }
    
    func done(selected date: Date, picker: TimePickerView) {
        if picker == reminderTimePicker {
            reminderTimeTextField.resignFirstResponder()
            
            reminderTimeOfDay = date
        } else if picker == startDatePickerView {
            startDateTextField.resignFirstResponder()
            
            if let activity = tempActivity {
                activity.updateFirstDate(to: Date.normalize(date: date))
                startDateTextField.text = dateFormatter.string(from: activity.firstDate)
            }
        }
    }

}
