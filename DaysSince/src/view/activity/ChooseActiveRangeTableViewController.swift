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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row > TableRows.DateRangeLabel.rawValue ? TableRows.DateRangeLabel.rawValue : indexPath.row
        let _ = setSelectedRow(row: TableRows(rawValue: row) ?? TableRows.AllYear)
        
        currentSelectedRow = TableRows(rawValue: row)!
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == TableRows.StartDate.rawValue {
            if currentSelectedRow != TableRows.DateRangeLabel {
                return 0
            } else {
                return 140
            }
        }

        if indexPath.row == TableRows.EndDate.rawValue {
            if currentSelectedRow != TableRows.DateRangeLabel {
                return 0
            } else {
                return 140
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

// MARK: Private Extension

extension ChooseActiveRangeTableViewController {

    // Sets the selected. Returns true if selection changes; Otherwise false.
    @discardableResult
    private func setSelectedRow(row:TableRows) -> Bool{
        guard row != currentSelectedRow else {
            return false
        }
        //let selectedRow = row.rawValue > TableRows.DateRangeLabel.rawValue ? .DateRangeLabel : row
        let selectedTableRow = super.tableView(tableView, cellForRowAt: IndexPath(row: currentSelectedRow.rawValue, section: 0))
        selectedTableRow.accessoryType = .none
        
        let selectedCell = super.tableView(tableView, cellForRowAt: IndexPath(row:row.rawValue, section: 0))
        selectedCell.accessoryType = .checkmark
        
        currentSelectedRow = row
        return true
    }
    
    private func updateInterval() {
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

}

// MARK: YearDayPickerDelegate
extension ChooseActiveRangeTableViewController : YearDayPickerDelegate {
    
    func yearDaySet(picker:UIPickerView, month: Int, monthSymbol:String, day: Int) {
        guard let startMonth = startDayPickerController?.getMonth(), let startDay = startDayPickerController?.getDay(), let endMonth = endDayPickerController?.getMonth(), let endDay = endDayPickerController?.getDay() else {
            return
        }
        dateRangeLabel.text = ActiveRangeMO.formatAsRange(startMonth: startMonth, startDay: startDay, endMonth: endMonth, endDay: endDay)
    }
    
}

