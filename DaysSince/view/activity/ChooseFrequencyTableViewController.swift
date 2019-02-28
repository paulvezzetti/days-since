//
//  ChooseFrequencyTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ChooseFrequencyTableViewController: UITableViewController {
    
    enum TableRows:Int {
        case Whenever = 0,
        ByDay,
        Weekly,
        WeekDayPicker,
        Monthly,
        MonthPicker,
        Yearly,
        YearDayPicker
    }
    
    @IBOutlet var byDateTableViewCell: UITableViewCell!
    @IBOutlet var weeklyTableViewCell: UITableViewCell!
    @IBOutlet var weekDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var monthlyTableViewCell: UITableViewCell!
    @IBOutlet var monthDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var yearlyTableViewCell: UITableViewCell!
    @IBOutlet var yearDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var wheneverTableViewCell: UITableViewCell!
    
    @IBOutlet var weekDayPicker: UIPickerView!
    @IBOutlet var monthDayPicker: UIPickerView!
    @IBOutlet var yearDayPicker: UIPickerView!


    var dayPickerController:ByDayPickerViewController?
    var monthDayPickerController :ByMonthDayPickerController?
    var yearDayPickerController: ByYearDayPickerController?

    var currentSelectedRow = TableRows.Whenever
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // TODO: Need to support updates by getting a reference to the activity from the delegate.
        
        // When no previous activity. Set the default to Whenever.
        wheneverTableViewCell.accessoryType = .checkmark
        
        dayPickerController = ByDayPickerViewController()
        weekDayPicker.dataSource = dayPickerController
        weekDayPicker.delegate = dayPickerController
        
        monthDayPickerController = ByMonthDayPickerController()
        monthDayPicker.delegate = monthDayPickerController
        monthDayPicker.dataSource = monthDayPickerController
        
        yearDayPickerController = ByYearDayPickerController()
        yearDayPicker.delegate = yearDayPickerController
        yearDayPicker.dataSource = yearDayPickerController
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row \(indexPath.row)")
        // Deselect the current selected row
        let currentSelection = super.tableView(tableView, cellForRowAt: IndexPath(row: currentSelectedRow.rawValue, section: 0))
        currentSelection.accessoryType = .none
        
        let selectedCell = super.tableView(tableView, cellForRowAt: indexPath)
        selectedCell.accessoryType = .checkmark
        
        
        currentSelectedRow = TableRows(rawValue: indexPath.row)!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }

}
