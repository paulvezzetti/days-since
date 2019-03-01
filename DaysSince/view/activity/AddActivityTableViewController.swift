//
//  AddTaskTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class AddActivityTableViewController: UITableViewController, DatePickerDelegate, IntervalSettingsDelegate {

    
    enum ActivityRows:Int {
        case TitleLabel = 0,
        TitleTextField,
        FrequencyLabel,
        FrequencyTextField,
        FrequencyDescLabel,
        StartFromDateEntry,
        NotificationLabel,
        NotificationButton
    }

    @IBOutlet var titleField: UITextField!
    @IBOutlet var frequencyField: UITextField!
    @IBOutlet var startDateLabel: UILabel!
    
    var chosenDate: Date = Date() {
        didSet {
            print("Set date")
        }
    }
    var dataManager: DataModelManager? = nil
    var editActivity: ActivityMO? = nil
    
    // These are the default values for the interval. They will be overwritten either by
    // user selections or by an existing activity which is being edited.
    private var intervalType:IntervalTypes = IntervalTypes.Unlimited
    private var intervalDay:Int = 0
    private var intervalMonth:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        startDateLabel.text = dateFormatter.string(from: chosenDate)
        
        if let activity = editActivity {
            titleField.text = activity.name
            frequencyField.text = String(activity.frequency)
            
        }
        
        //startDateLabel.text = new Date().description

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        startDateLabel.text = dateFormatter.string(from: chosenDate)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
//        switch section {
//        case 0:
//            return 1
//        case 1:
//            return 2
//        case 2:
//            return 3
//        default:
//            return 1
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if /*indexPath.section == 1 &&*/ indexPath.row == ActivityRows.StartFromDateEntry.rawValue {
            self.performSegue(withIdentifier: "showDatePicker", sender: self)
        } else if indexPath.row == ActivityRows.FrequencyTextField.rawValue {
           // self.performSegue(withIdentifier: "chooseWhenSegue", sender: self)
        }
    }

        /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDatePicker" {
            let controller = segue.destination as! DatePickerViewController
            controller.delegate = self
            controller.initialDate = chosenDate
        } else if segue.identifier == "chooseWhenSegue" {
            let controller = segue.destination as! ChooseFrequencyTableViewController
            //controller.dataManager = dataManager
            controller.settingsDelegate = self
        }

    }

    func getInitialIntervalSettings() -> (type: IntervalTypes, day: Int, month: Int) {
        return (type: IntervalTypes.Monthly, day: 23, month: 4)
    }

    
    func applyIntervalSettings(type: IntervalTypes, day: Int, month: Int) {
        print("Interval settings: \(type.rawValue) on day: \(day) on month: \(month)")
    }

    @IBAction func doSave(_ sender: Any) {
        if let dm = dataManager {
            if editActivity != nil {
                updateActivity(dm)
            } else {
                createNewActivity(dm)
            }
//            do {
//                try dm.newActivity(named: titleField.text!, every: Int(frequencyField.text!) ?? 0, starting: chosenDate)
//                try dm.saveContext()
//            } catch {
//                print("Error saving activity")
//            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func saveActivity() {
        if let dm = dataManager {
            if editActivity != nil {
                updateActivity(dm)
            } else {
                createNewActivity(dm)
            }
        }
    }
    
    
    @IBAction func cancelAdd(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func createNewActivity(_ dataManager: DataModelManager) {
        do {
            try dataManager.newActivity(named: titleField.text!, every: Int(frequencyField.text!) ?? 0, starting: chosenDate)
            try dataManager.saveContext()
        } catch {
            print("Error saving activity")
        }
    }
    
    func updateActivity(_ dataManager: DataModelManager) {
        if editActivity!.name != titleField.text! {
            editActivity!.name = titleField.text!
        }
        if editActivity!.frequency != Int16(frequencyField.text!) {
            editActivity!.frequency = Int16(frequencyField.text!) ?? 0
        }
    }
}
