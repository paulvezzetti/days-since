//
//  ChooseIntervalTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ChooseIntervalTableViewController: UITableViewController, WeekDayPickerDelegate,
                                            MonthDayPickerDelegate,
                                            YearDayPickerDelegate, UITextFieldDelegate {
    
    
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
    
    // MARK: Outlets
    @IBOutlet var byDayTableViewCell: UITableViewCell!
    @IBOutlet var weeklyTableViewCell: UITableViewCell!
    @IBOutlet var weekDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var monthlyTableViewCell: UITableViewCell!
    @IBOutlet var monthDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var yearlyTableViewCell: UITableViewCell!
    @IBOutlet var yearDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var wheneverTableViewCell: UITableViewCell!
    
    @IBOutlet var byDayTextField: UITextField!
    @IBOutlet var weeklyLabel: UILabel!
    @IBOutlet var monthlyLabel: UILabel!
    @IBOutlet var yearlyLabel: UILabel!
    @IBOutlet var weekDayPicker: UIPickerView!
    @IBOutlet var monthDayPicker: UIPickerView!
    @IBOutlet var yearDayPicker: UIPickerView!

    @IBOutlet var byWeekdayLabel: UILabel!
    @IBOutlet var byMonthDayLabel: UILabel!
    @IBOutlet var byYearDayLabel: UILabel!
    
    // MARK: Private variables
    private var currentSelectedRow = TableRows.Whenever
    private var weekdayPickerController:WeekDayPickerController?
    private var monthDayPickerController: MonthDayPickerController?
    private var yearDayPickerController: YearDayPickerController?
    
    // MARK: Public
    var activity:ActivityMO? = nil
    
    deinit {
        print("Destroying the ChooseFrequencyTVController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("Creating a ChooseFreqTVController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // This makes the empty table cells not show up.
        tableView.tableFooterView = UIView(frame: .zero)

        // Set up the pickers
        weekdayPickerController = WeekDayPickerController(picker: weekDayPicker, delegate: self)
        monthDayPickerController = MonthDayPickerController(picker:monthDayPicker, delegate: self)
        yearDayPickerController = YearDayPickerController(picker: yearDayPicker, delegate: self)
        
        // Set up by-day text field
        byDayTextField.delegate = self
        

        // Configure the UI based on the activity, if any
        if let interval = activity?.interval {
            switch interval {
            case is UnlimitedIntervalMO:
                wheneverTableViewCell.accessoryType = .checkmark
                currentSelectedRow = .Whenever
            case let constantInterval as ConstantIntervalMO:
                byDayTableViewCell.accessoryType = .checkmark
                byDayTextField.text = String(constantInterval.frequency)
                currentSelectedRow = .ByDay
            case let weeklyInterval as WeeklyIntervalMO:
                weeklyTableViewCell.accessoryType = .checkmark
                weekdayPickerController?.setWeekday(to: Int(weeklyInterval.day))
                weeklyLabel.text = Weekdays.day(for: weekdayPickerController?.getWeekday() ?? 0)
                currentSelectedRow = .Weekly
            case let monthlyInterval as MonthlyIntervalMO:
                monthlyTableViewCell.accessoryType = .checkmark
                monthDayPickerController?.setDay(Int(monthlyInterval.day))
                monthlyLabel.text = String(monthDayPickerController?.getDay() ?? 1)
                currentSelectedRow = .Monthly
            case let yearlyInterval as YearlyIntervalMO:
                yearlyTableViewCell.accessoryType = .checkmark
                yearDayPickerController?.setYearDay(month: Int(yearlyInterval.month), day: Int(yearlyInterval.day))
                yearlyLabel.text = Months.month(for: yearDayPickerController?.getMonth() ?? 0) + " " + String(yearDayPickerController?.getDay() ?? 4)
                currentSelectedRow = .Yearly
            default:
                wheneverTableViewCell.accessoryType = .checkmark
                currentSelectedRow = .Whenever

            }

        } else {
            wheneverTableViewCell.accessoryType = .checkmark
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
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectionChanged = setSelectedRow(row: TableRows(rawValue: indexPath.row) ?? TableRows.Whenever)
        
        currentSelectedRow = TableRows(rawValue: indexPath.row)!
        
//        if selectionChanged {
//            updateInterval()
//        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Height for row: \(indexPath.row)")
        if indexPath.row == TableRows.MonthPicker.rawValue {
            if currentSelectedRow != TableRows.Monthly {
                return 0
            } else {
                return 120
            }
        }
        if indexPath.row == TableRows.WeekDayPicker.rawValue {
            if currentSelectedRow != TableRows.Weekly {
                return 0
            } else {
                return 120
            }
        }
        if indexPath.row == TableRows.YearDayPicker.rawValue {
            if currentSelectedRow != TableRows.Yearly {
                return 0
            } else {
                return 120
            }
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    // Sets the selected. Returns true if selection changes; Otherwise false.
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
        guard let act = activity, let moc = act.managedObjectContext else {
            return
        }
        
        // Create a new interval
        var interval:IntervalMO? = nil
        
        switch currentSelectedRow {
        case .Whenever:
            interval = UnlimitedIntervalMO(context: moc)
        case .ByDay:
            interval = ConstantIntervalMO(context: moc)
            (interval as! ConstantIntervalMO).frequency = Int16(byDayTextField.text ?? "1") ?? 1
        case .Weekly:
            interval = WeeklyIntervalMO(context:moc)
            (interval as! WeeklyIntervalMO).day = Int16(weekdayPickerController?.getWeekday() ?? 0)
        case .Monthly:
            interval = MonthlyIntervalMO(context:moc)
            (interval as! MonthlyIntervalMO).day = Int16(monthDayPicker.selectedRow(inComponent: 0))
        case .Yearly:
            interval = YearlyIntervalMO(context: moc)
            (interval as! YearlyIntervalMO).month = Int16(yearDayPickerController?.getMonth() ?? 2)
            (interval as! YearlyIntervalMO).day = Int16(yearDayPickerController?.getDay() ?? 10)
        default:
            break
        }
        act.interval = interval
    }
    
    //TODO: Is there a way to combine these??
    
    // MARK: ByDatePickerDelegate
    func weekdaySet(day:Int, symbol:String) {
        byWeekdayLabel.text! = symbol // TODO: Update the interval
    }

    // MARK: ByMonthDayPickerDelegate
    func monthDaySet(_ day: Int, formattedValue: String) {
        byMonthDayLabel.text! = formattedValue
    }

    // MARK: ByYearDayPickerDelegate
    func yearDaySet(month: Int, monthSymbol:String, day: Int) {
        byYearDayLabel.text = monthSymbol + " " + String(day) // TODO: Update the interval
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setSelectedRow(row: TableRows.ByDay)
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()

        return true
    }
    
}