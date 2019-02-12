//
//  AddTaskTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class AddActivityTableViewController: UITableViewController, DatePickerDelegate {
    
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
    
    var chosenDate: Date = Date()
    var dataManager: DataModelManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        startDateLabel.text = dateFormatter.string(from: chosenDate)
        
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
        return 8
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
        if (segue.identifier == "showDatePicker") {
            let controller = segue.destination as! DatePickerViewController
            controller.delegate = self
            controller.initialDate = chosenDate
        }

    }


    @IBAction func doSave(_ sender: Any) {
        if let dm = dataManager {
            do {
                try dm.newActivity(named: titleField.text!, every: Int(frequencyField.text!) ?? 0, starting: chosenDate)
                try dm.saveContext()
            } catch {
                print("Error saving activity")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelAdd(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
