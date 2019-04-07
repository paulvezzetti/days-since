//
//  ChooseActiveRangeTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/6/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ChooseActiveRangeTableViewController: UITableViewController {

    enum TableRows:Int {
        case AllYear = 0,
        DateRangeLabel,
        StartDate,
        EndDate
    }
    // MARK: Outlets
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var startDatePickerView: UIPickerView!
    @IBOutlet weak var endDatePickerView: UIPickerView!
    
    @IBOutlet weak var allYearTableViewCell: UITableViewCell!
    @IBOutlet weak var dateRangeTableViewCell: UITableViewCell!
    
    
    // MARK: Private variables
    private var currentSelectedRow = TableRows.AllYear
    private var startDayPickerController: YearDayPickerController?
    private var endDayPickerController: YearDayPickerController?


    // MARK: Public
    var activity:ActivityMO? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This makes the empty table cells not show up.
        tableView.tableFooterView = UIView(frame: .zero)

        startDayPickerController = YearDayPickerController(picker: startDatePickerView, delegate: self)
        endDayPickerController = YearDayPickerController(picker: endDatePickerView, delegate: self)

        if let activeRange = activity?.interval?.activeRange {
            dateRangeTableViewCell.accessoryType = .checkmark
            currentSelectedRow = .DateRangeLabel

            startDayPickerController?.setYearDay(month: Int(activeRange.startMonth), day: Int(activeRange.startDay))
            endDayPickerController?.setYearDay(month: Int(activeRange.endMonth), day: Int(activeRange.endDay))

        } else {
            allYearTableViewCell.accessoryType = .checkmark
            currentSelectedRow = .AllYear
            
            startDayPickerController?.setYearDay(month: 1, day: 1)
            endDayPickerController?.setYearDay(month: 12, day: 31)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateInterval()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectionChanged = setSelectedRow(row: TableRows(rawValue: indexPath.row) ?? TableRows.AllYear)
        
        currentSelectedRow = TableRows(rawValue: indexPath.row)!
        
        if selectionChanged {
//            updateInterval()
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Height for row: \(indexPath.row)")
        if indexPath.row == TableRows.StartDate.rawValue {
            if currentSelectedRow != TableRows.DateRangeLabel {
                return 0
            } else {
                return 120
            }
        }
        
        if indexPath.row == TableRows.EndDate.rawValue {
            if currentSelectedRow != TableRows.DateRangeLabel {
                return 0
            } else {
                return 120
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    // Sets the selected. Returns true if selection changes; Otherwise false.
    @discardableResult
    func setSelectedRow(row:TableRows) -> Bool{
        guard row != currentSelectedRow else {
            return false
        }
        let selectedTableRow = super.tableView(tableView, cellForRowAt: IndexPath(row: currentSelectedRow.rawValue, section: 0))
        selectedTableRow.accessoryType = .none
        
        let selectedCell = super.tableView(tableView, cellForRowAt: IndexPath(row:row.rawValue, section: 0))
        selectedCell.accessoryType = .checkmark
        
        currentSelectedRow = row
        return true
    }
    
    func updateInterval() {
        guard let act = activity, let interval = act.interval, let moc = act.managedObjectContext else {
            return
        }

        if currentSelectedRow == .AllYear && interval.activeRange != nil {
            interval.activeRange = nil
        } else if currentSelectedRow == .DateRangeLabel {
            var range = interval.activeRange
            if range == nil {
                range = ActiveRangeMO(context: moc)
                interval.activeRange = range
            }
            range?.startDay = Int16(startDayPickerController?.getDay() ?? 1)
            range?.startMonth = Int16(startDayPickerController?.getMonth() ?? 1)
            range?.endDay = Int16(endDayPickerController?.getDay() ?? 31)
            range?.endMonth = Int16(endDayPickerController?.getMonth() ?? 12)
            
        }
                
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: ByYearDayPickerDelegate
extension ChooseActiveRangeTableViewController : YearDayPickerDelegate {
    
    func yearDaySet(picker:UIPickerView, month: Int, monthSymbol:String, day: Int) {
        guard let startMonth = startDayPickerController?.getMonth(), let startDay = startDayPickerController?.getDay(), let endMonth = endDayPickerController?.getMonth(), let endDay = endDayPickerController?.getDay() else {
            return
        }
        dateRangeLabel.text = "From " + Months.month(for: startMonth) + " " + String(startDay) + " to " + Months.month(for: endMonth) + " " + String(endDay)
    }
    
}

