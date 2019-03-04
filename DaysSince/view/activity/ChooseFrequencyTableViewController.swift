//
//  ChooseFrequencyTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ChooseFrequencyTableViewController: UITableViewController, ByDayPickerDelegate,
                                            ByMonthDayPickerDelegate,
                                            ByYearDayPickerDelegate, UITextFieldDelegate {
    
    
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
    
    private var currentSelectedRow = TableRows.Whenever
    private var weekdayPickerController:WeekDayPickerViewController?
    private var monthDayPickerController: ByMonthDayPickerController?
    private var yearDayPickerController: ByYearDayPickerController?
    
    var activity:ActivityMO? = nil
//    var settingsDelegate:IntervalSettingsDelegate? = nil
    
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
//
//        // Set up the pickers
        weekdayPickerController = WeekDayPickerViewController(picker: weekDayPicker, delegate: self)
        
        monthDayPickerController = ByMonthDayPickerController(delegate: self)
        monthDayPicker.delegate = monthDayPickerController
        monthDayPicker.dataSource = monthDayPickerController
        
        yearDayPickerController = ByYearDayPickerController(delegate: self)
        yearDayPicker.delegate = yearDayPickerController
        yearDayPicker.dataSource = yearDayPickerController
        
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
//                weekDayPicker.selectRow(Int(weeklyInterval.day), inComponent: 0, animated: false)
                // TODO: Switch to Calendar
                weeklyLabel.text = Weekdays.day(for: weekdayPickerController?.getWeekday() ?? 0)
                currentSelectedRow = .Weekly
            case let monthlyInterval as MonthlyIntervalMO:
                monthlyTableViewCell.accessoryType = .checkmark
                monthDayPicker.selectRow(Int(monthlyInterval.day), inComponent: 0, animated: false)
                monthlyLabel.text = DaysOfMonth().formattedValueForIndex(Int(monthlyInterval.day))
                currentSelectedRow = .Monthly
            case let yearlyInterval as YearlyIntervalMO:
                yearlyTableViewCell.accessoryType = .checkmark
                yearDayPicker.selectRow(Int(yearlyInterval.month), inComponent: 0, animated: false)
                yearDayPicker.selectRow(Int(yearlyInterval.day), inComponent: 1, animated: false)
                yearlyLabel.text = Months.fromIndex(Int(yearlyInterval.month)).rawValue + " " + String(Int(yearlyInterval.day) + 1)
                currentSelectedRow = .Yearly
            default:
                wheneverTableViewCell.accessoryType = .checkmark
                currentSelectedRow = .Whenever

            }

        } else {
            wheneverTableViewCell.accessoryType = .checkmark
        }

        
//        if let delegate = settingsDelegate {
//            let initialSettings = delegate.getInitialIntervalSettings()
//            switch initialSettings.type {
//            case IntervalTypes.Unlimited:
//                wheneverTableViewCell.accessoryType = .checkmark
//                currentSelectedRow = .Whenever
//            case IntervalTypes.Constant:
//                byDayTableViewCell.accessoryType = .checkmark
//                byDayTextField.text = String(initialSettings.day)
//                currentSelectedRow = .ByDay
//            case IntervalTypes.Weekly:
//                weeklyTableViewCell.accessoryType = .checkmark
//                weekDayPicker.selectRow(initialSettings.day, inComponent: 0, animated: false)
//                weeklyLabel.text = DaysOfWeek.fromIndex(initialSettings.day).rawValue
//                currentSelectedRow = .Weekly
//            case IntervalTypes.Monthly:
//                monthlyTableViewCell.accessoryType = .checkmark
//                monthDayPicker.selectRow(initialSettings.day, inComponent: 0, animated: false)
//                monthlyLabel.text = DaysOfMonth().formattedValueForIndex(initialSettings.day) //monthDayPickerController?.formattedValueForIndex(initialSettings.day)
//                currentSelectedRow = .Monthly
//            case IntervalTypes.Yearly:
//                yearlyTableViewCell.accessoryType = .checkmark
//                yearDayPicker.selectRow(initialSettings.month, inComponent: 0, animated: false)
//                yearDayPicker.selectRow(initialSettings.day, inComponent: 1, animated: false)
//                yearlyLabel.text = Months.fromIndex(initialSettings.month).rawValue + " " + String(initialSettings.day + 1)
//                currentSelectedRow = .Yearly
//            }
//
//        } else {
//            wheneverTableViewCell.accessoryType = .checkmark
//        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateInterval()
//
//        // Notify the delegate of the changes
//
//        var iType:IntervalTypes = IntervalTypes.Unlimited
//        var day:Int = 0
//        var month:Int = 0
//        switch currentSelectedRow {
//        case .Whenever:
//            iType = IntervalTypes.Unlimited
//        case .ByDay:
//            iType = IntervalTypes.Constant
//            day = Int(byDayTextField.text ?? "1") ?? 1
//        case .Weekly:
//            iType = IntervalTypes.Weekly
//            day = weekDayPicker.selectedRow(inComponent: 0)
//        case .Monthly:
//            iType = IntervalTypes.Monthly
//            day = monthDayPicker.selectedRow(inComponent: 0)
//        case .Yearly:
//            iType = IntervalTypes.Yearly
//            month = yearDayPicker.selectedRow(inComponent: 0)
//            day = yearDayPicker.selectedRow(inComponent: 1) + 1
//        default:
//            break
//        }
//
//        settingsDelegate?.applyIntervalSettings(type: iType, day: day, month: month)
//        settingsDelegate = nil
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
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 7
//    }
    
    
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
            (interval as! YearlyIntervalMO).month = Int16(yearDayPicker.selectedRow(inComponent: 0))
            (interval as! YearlyIntervalMO).day = Int16(yearDayPicker.selectedRow(inComponent: 1))
        default:
            break
        }
        act.interval = interval
    }
    
    //TODO: Is there a way to combine these??
    
    // MARK: ByDatePickerDelegate
    func weekdayChosen(index:Int, value:String) {
        byWeekdayLabel.text! = value // TODO: Update the interval
    }

    // MARK: ByMonthDayPickerDelegate
    func pickerValueChanged(_ day: Int, formattedValue: String) {
        byMonthDayLabel.text! = formattedValue
    }

    // MARK: ByYearDayPickerDelegate
    func pickerValueChanged(month: Int, day: Int) {
        byYearDayLabel.text = Months.fromIndex(month).rawValue + " " + String(day + 1)
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setSelectedRow(row: TableRows.ByDay)
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()

        return true
    }
    
}
