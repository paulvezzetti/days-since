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

class AddActivityTableViewController: UITableViewController, UITextFieldDelegate {

    
    private enum ActivityRows:Int {
        case TitleLabel = 0,
        TitleTextField,
        FrequencyLabel,
        FrequencyDescLabel,
        StartFromDateLabel,
        StartFromDatePicker,
        NotificationLabel,
        NotificationButton
    }

    // MARK: - Outlets
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var startDateLabel: UILabel!
    @IBOutlet private var intervalLabel: UILabel!
    
    @IBOutlet private var startDatePicker: UIDatePicker!
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var enableNotificationsSwitch: UISwitch!
    @IBOutlet private var remindTextField: UITextField!
    @IBOutlet private var snoozeSwitch: UISwitch!
    @IBOutlet private var snoozeTextField: UITextField!

    // MARK: - Public properties
    var editActivity: ActivityMO? = nil
    var dataManager: DataModelManager? = nil
    
    // MARK: - Private properties
    private var managedObjectContext: NSManagedObjectContext? = nil
    
    private var tempActivity: ActivityMO? = nil
    
    private var isStartDatePickerShowing: Bool = false
    
    private let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        return formatter
    }()
        
    deinit {
        print("Destroying the AddActivityTableViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("Creating a AddActivityTableViewController")
    }

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
        
        
        // Copy the settings to the temp activity
        if let activityToEdit = editActivity {
            // If we are editing an existing activity, clone it with just the first event history
            tempActivity = activityToEdit.clone(context: context, eventCloneOptions: .First)
        } else {
            // Otherwise, initialize a new one
            self.tempActivity = ActivityMO(context: context)
            self.tempActivity?.id = UUID()
            self.tempActivity?.notifications = NotificationMO(context: context)
            self.tempActivity?.interval = UnlimitedIntervalMO(context: context)
            let firstEvent = EventMO(context: context)
            firstEvent.timestamp = Date.normalize(date: Date())
            print("Event timestamp: \(firstEvent.timestamp!.getLongString())")

            self.tempActivity?.addToHistory(firstEvent)
        }
        
        titleField.delegate = self

        // Fill in the initial values
        configureViewForActivity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureViewForActivity()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let needToShowDatePicker:Bool = (indexPath.row == ActivityRows.StartFromDateLabel.rawValue && !isStartDatePickerShowing)
        let needToHideDataPicker:Bool = (indexPath.row != ActivityRows.StartFromDateLabel.rawValue && isStartDatePickerShowing)
        
        isStartDatePickerShowing = needToShowDatePicker
        if needToShowDatePicker || needToHideDataPicker {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == ActivityRows.StartFromDatePicker.rawValue {
            if isStartDatePickerShowing {
                return 138
            } else {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
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
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }

        guard let activity = tempActivity else {
            return
        }
        
        activity.name = titleField.text!
        activity.notifications?.enabled = enableNotificationsSwitch.isOn
        activity.notifications?.allowSnooze = snoozeSwitch.isOn
        activity.notifications?.daysBefore = Int16(remindTextField.text ?? "1") ?? 1
        activity.notifications?.snooze = Int16(snoozeTextField.text ?? "1") ?? 1
        
        // TODO: Update activity and save
        if let activityToUpdate = editActivity {
            if activity.name != activityToUpdate.name {
                activityToUpdate.name = activity.name
            }
            
            if activity.interval !== activityToUpdate.interval { // TODO: Need equals method
                if let parentMoc = managedObjectContext?.parent {
                    activityToUpdate.interval = activity.interval?.clone(context: parentMoc)
                }
            }
            let firstDate = activity.firstDate
            if firstDate != activityToUpdate.firstDate {
                activityToUpdate.updateFirstDate(to: Date.normalize(date:firstDate))
            }
            
            activityToUpdate.notifications?.enabled = activity.notifications?.enabled ?? false
            activityToUpdate.notifications?.allowSnooze = activity.notifications?.allowSnooze ?? false
            activityToUpdate.notifications?.daysBefore = activity.notifications?.daysBefore ?? 1
            activityToUpdate.notifications?.snooze = activity.notifications?.snooze ?? 1
            
            
        } else {
            // Save the context
            do {
                try managedObjectContext?.save()
            } catch let error as NSError {
                print("Unable to save new activity: \(error)")
            }
        }
        
        
    }

    func initializeManagedObjectContext() throws {
        if self.managedObjectContext == nil {
            self.managedObjectContext = try dataManager?.newChildManagedObjectContext()
        }
    }
    
    func configureViewForActivity() {
        guard let activity = tempActivity else {
            return
        }
        titleField.text = activity.name
        intervalLabel.text = activity.interval!.toPrettyString()
        startDateLabel.text = dateFormatter.string(from: activity.firstDate)
        
        let title = titleField.text ?? ""
        saveButton.isEnabled = !title.isEmpty
        
        let enableNotifications = activity.notifications?.enabled ?? false
        enableNotificationsSwitch.isEnabled = true
        enableNotificationsSwitch.setOn(enableNotifications, animated: false)
        remindTextField.isEnabled = enableNotifications
        remindTextField.text = String(activity.notifications?.daysBefore ?? 1)
        snoozeSwitch.setOn(enableNotifications, animated: false)
        snoozeSwitch.isSelected = activity.notifications?.allowSnooze ?? false
        snoozeTextField.isEnabled = enableNotifications
        snoozeTextField.text = String(activity.notifications?.snooze ?? 1)

    }
    
    
    @IBAction func enableNotificationsChanged(_ sender: Any) {
        let enableNotifications = enableNotificationsSwitch.isOn
        if enableNotifications {
            // Check for push permission. This is async. If it fails, we will disable notifications.
            requestPermissionForPushNotifications()
        }
        tempActivity?.notifications?.enabled = enableNotifications
        remindTextField.isEnabled = enableNotifications
        snoozeSwitch.isEnabled = enableNotifications
        snoozeTextField.isEnabled = enableNotifications
    }
    
    @IBAction func startDateValueChanged(_ sender: Any) {
        startDateLabel.text = dateFormatter.string(from: startDatePicker.date)
        tempActivity?.updateFirstDate(to: Date.normalize(date: startDatePicker.date))
    }
    
    @IBAction func cancelAdd(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    // TODO: This needs to move to some type of Notification Manager for the app
    func requestPermissionForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            print("Permission granted: \(granted)")
            
        }
    }

    
    @IBAction func titleFieldChanged(_ sender: Any) {
        
        let title = titleField.text ?? ""
        saveButton.isEnabled = !title.isEmpty
        navigationItem.title = title
    }
    
    
    // MARK -  UITextFieldDelegate
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField === titleField {
            let title = textField.text ?? ""
            saveButton.isEnabled = !title.isEmpty
            navigationItem.title = title
            tempActivity?.name = title
        }
    }
}
