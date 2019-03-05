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

    
    enum ActivityRows:Int {
        case TitleLabel = 0,
        TitleTextField,
        FrequencyLabel,
        FrequencyDescLabel,
        StartFromDateLabel,
        StartFromDatePicker,
        NotificationLabel,
        NotificationButton
    }

    @IBOutlet var titleField: UITextField!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var intervalLabel: UILabel!
    
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var enableNotificationsSwitch: UISwitch!
    
    var dataManager: DataModelManager? = nil {
        didSet {
            do {
                self.managedObjectContext = try dataManager?.newChildManagedObjectContext()
                if let context = self.managedObjectContext {
                    self.tempActivity = ActivityMO(context: context)
                    self.tempActivity?.id = UUID()
                }
            } catch {
                print("Unable to get child managed object context")
            }
        }
    }
    private var managedObjectContext: NSManagedObjectContext? = nil
    
    var editActivity: ActivityMO? = nil
    var tempActivity: ActivityMO? = nil
    
    private var isStartDatePickerShowing: Bool = false
    
    let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        return formatter
    }()
    
    // These are the default values for the interval. They will be overwritten either by
    // user selections or by an existing activity which is being edited.
    private var intervalType:IntervalTypes = IntervalTypes.Unlimited
    private var intervalDay:Int = 0
    private var intervalMonth:Int = 0
    
    deinit {
        print("Destroying the AddActivityTableViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("Creating a AddActivityTableViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let activity = tempActivity, let moc = managedObjectContext else {
            // TODO: Show an error to user
            return
        }
        
        titleField.delegate = self
        
        // Copy the settings to the temp activity
        if let activityToEdit = editActivity {
            activity.name = activityToEdit.name
            if activityToEdit.interval != nil {
                // Make a copy
                activity.interval = activityToEdit.interval?.clone(context: moc)
            }
            // Only really need the first day, not the whole history
            let firstEvent = EventMO(context: moc)
            firstEvent.timestamp = activityToEdit.firstDate
            activity.addToHistory(firstEvent)
            
            
        } else {
            // Set some defaults
            activity.interval = UnlimitedIntervalMO(context: moc)
            let firstEvent = EventMO(context: moc)
            firstEvent.timestamp = Date()
            activity.addToHistory(firstEvent)
        }
        // Fill in the initial values
        configureViewForActivity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureViewForActivity()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        //print("Height for row: \(indexPath.row)")
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        /*if segue.identifier == "showDatePicker" {
            let controller = segue.destination as! DatePickerViewController
            controller.delegate = self
            controller.initialDate = chosenDate
        } else */if segue.identifier == "chooseWhenSegue" {
            let controller = segue.destination as! ChooseIntervalTableViewController
            //controller.dataManager = dataManager
            //controller.settingsDelegate = self
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
                activityToUpdate.updateFirstDate(to: firstDate)
            }
            
            
        } else {
            // Save the context
            do {
                try managedObjectContext?.save()
            } catch let error as NSError {
                print("Unable to save new activity: \(error)")
            }
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
    }
    
    @IBAction func enableNotificationsChanged(_ sender: Any) {
        if enableNotificationsSwitch.isOn {
            requestPermissionForPushNotifications()
        }
        
        
    }
    
    @IBAction func startDateValueChanged(_ sender: Any) {
        startDateLabel.text = dateFormatter.string(from: startDatePicker.date)
        tempActivity?.updateFirstDate(to: startDatePicker.date)
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
