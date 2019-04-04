//
//  ChooseIntervalTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ChooseIntervalTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    enum TableRows:Int {
        case Whenever = 0,
        ByDay,
        ByDateComponent,
        ByDateComponentPicker,
        Weekly,
        WeekDayPicker,
        Monthly,
        MonthPicker,
        Yearly,
        YearDayPicker
    }
    
    // MARK: Outlets
    @IBOutlet var byDayTableViewCell: UITableViewCell!
    @IBOutlet var byDateComponentTableViewCell: UITableViewCell!
    @IBOutlet var byDateComponentPickerTableViewCell: UITableViewCell!
    @IBOutlet var weeklyTableViewCell: UITableViewCell!
    @IBOutlet var weekDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var monthlyTableViewCell: UITableViewCell!
    @IBOutlet var monthDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var yearlyTableViewCell: UITableViewCell!
    @IBOutlet var yearDayPickerTableViewCell: UITableViewCell!
    @IBOutlet var wheneverTableViewCell: UITableViewCell!
    
    @IBOutlet var byDayTextField: UITextField!
    @IBOutlet var byDateComponentLabel: UILabel!
    @IBOutlet var weeklyLabel: UILabel!
    @IBOutlet var monthlyLabel: UILabel!
    @IBOutlet var yearlyLabel: UILabel!
    @IBOutlet var byDateComponentPicker: UIPickerView!
    @IBOutlet var weekDayPicker: UIPickerView!
    @IBOutlet var monthDayPicker: UIPickerView!
    @IBOutlet var yearDayPicker: UIPickerView!

    @IBOutlet var byWeekdayLabel: UILabel!
    @IBOutlet var byMonthDayLabel: UILabel!
    @IBOutlet var byYearDayLabel: UILabel!
    
    // MARK: Private variables
    private var currentSelectedRow = TableRows.Whenever
    private var byDateComponentPickerController:ScaleDateComponentPickerController?
    private var weekdayPickerController:WeekDayPickerController?
    private var monthDayPickerController: MonthDayPickerController?
    private var yearDayPickerController: YearDayPickerController?
    
    // MARK: Public
    var activity:ActivityMO? = nil
    
//    deinit {
//        print("Destroying the ChooseFrequencyTVController")
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        print("Creating a ChooseFreqTVController")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // This makes the empty table cells not show up.
        tableView.tableFooterView = UIView(frame: .zero)

        // Set up the pickers
        byDateComponentPickerController = ScaleDateComponentPickerController(picker: byDateComponentPicker, delegate: self)
        weekdayPickerController = WeekDayPickerController(picker: weekDayPicker, delegate: self)
        monthDayPickerController = MonthDayPickerController(picker:monthDayPicker, delegate: self)
        yearDayPickerController = YearDayPickerController(picker: yearDayPicker, delegate: self)
        
        // Set up by-day text field
        byDayTextField.delegate = self
        let calendar = Calendar.current
        let todayAsDateComponents = calendar.dateComponents([ .day, .month, .weekday], from: Date())
        
        weekdayPickerController?.setWeekday(to: todayAsDateComponents.weekday ?? 0)
        weeklyLabel.text = Weekdays.day(for: todayAsDateComponents.weekday ?? 0)
        
        monthDayPickerController?.setDay(todayAsDateComponents.day ?? 1)
        monthlyLabel.text = NumberFormatterOrdinal.string(todayAsDateComponents.day ?? 1)
        
        yearDayPickerController?.setYearDay(month: todayAsDateComponents.month ?? 1, day: todayAsDateComponents.day ?? 1)
        yearlyLabel.text = Months.month(for: todayAsDateComponents.month ?? 0) + " " + String(todayAsDateComponents.day ?? 1)
        
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
                monthlyLabel.text = NumberFormatterOrdinal.string(monthDayPickerController?.getDay() ?? 1)
                currentSelectedRow = .Monthly
            case let yearlyInterval as YearlyIntervalMO:
                yearlyTableViewCell.accessoryType = .checkmark
                yearDayPickerController?.setYearDay(month: Int(yearlyInterval.month), day: Int(yearlyInterval.day))
                yearlyLabel.text = Months.month(for: yearDayPickerController?.getMonth() ?? 0) + " " + String(yearDayPickerController?.getDay() ?? 1)
                currentSelectedRow = .Yearly
            case let offsetInterval as OffsetIntervalMO:
                byDateComponentTableViewCell.accessoryType = .checkmark
                byDateComponentPickerController?.setScaleDateComponent(component: offsetInterval.intervalType(), scale: Int(offsetInterval.offset))
                byDateComponentLabel.text = offsetInterval.toPrettyString()
                currentSelectedRow = .ByDateComponent
//            case let weekOffsetInterval as WeekOffsetIntervalMO:
//                byDateComponentTableViewCell.accessoryType = .checkmark
//                byDateComponentPickerController?.setScaleDateComponent(component: .Week, scale: Int(weekOffsetInterval.weeks))
//                byDateComponentLabel.text = weekOffsetInterval.toPrettyString()
//                currentSelectedRow = .ByDateComponent
//            case let yearOffsetInterval as YearOffsetIntervalMO:
//                byDateComponentTableViewCell.accessoryType = .checkmark
//                byDateComponentPickerController?.setScaleDateComponent(component: .Year, scale: Int(yearOffsetInterval.years))
//                byDateComponentLabel.text = yearOffsetInterval.toPrettyString()
//                currentSelectedRow = .ByDateComponent
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectionChanged = setSelectedRow(row: TableRows(rawValue: indexPath.row) ?? TableRows.Whenever)
        
        currentSelectedRow = TableRows(rawValue: indexPath.row)!
        
        if selectionChanged {
            updateInterval()
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Height for row: \(indexPath.row)")
        if indexPath.row == TableRows.ByDateComponentPicker.rawValue {
            if currentSelectedRow != TableRows.ByDateComponent {
                return 0
            } else {
                return 120
            }
        }

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
        guard let act = activity, let moc = act.managedObjectContext else {
            return
        }
        
        // Create a new interval
        var interval:IntervalMO? = act.interval
        
        switch currentSelectedRow {
        case .Whenever:
            if !(interval is UnlimitedIntervalMO) {
                interval = UnlimitedIntervalMO(context: moc)
                act.interval = interval
            }
        case .ByDay:
            if !(interval is ConstantIntervalMO) {
                interval = ConstantIntervalMO(context: moc)
                act.interval = interval
            }
            (interval as! ConstantIntervalMO).frequency = Int16(byDayTextField.text ?? "1") ?? 1
        case .Weekly:
            if !(interval is WeeklyIntervalMO) {
                interval = WeeklyIntervalMO(context:moc)
                act.interval = interval
            }
            (interval as! WeeklyIntervalMO).day = Int16(weekdayPickerController?.getWeekday() ?? 0)
        case .Monthly:
            if !(interval is MonthlyIntervalMO) {
                interval = MonthlyIntervalMO(context:moc)
                act.interval = interval
            }
            (interval as! MonthlyIntervalMO).day = Int16(monthDayPickerController?.getDay() ?? 1)
        case .Yearly:
            if !(interval is YearlyIntervalMO) {
                interval = YearlyIntervalMO(context:moc)
                act.interval = interval
            }
            (interval as! YearlyIntervalMO).month = Int16(yearDayPickerController?.getMonth() ?? 2)
            (interval as! YearlyIntervalMO).day = Int16(yearDayPickerController?.getDay() ?? 10)
        case .ByDateComponent:
            let component = byDateComponentPickerController?.getComponent() ?? .Week
            let scale = byDateComponentPickerController?.getScale() ?? 1
            switch component {
            case .Week:
                if !(interval is WeekOffsetIntervalMO) {
                    interval = WeekOffsetIntervalMO(context: moc)
                    act.interval = interval
                }
            case .Month:
                if !(interval is MonthOffsetIntervalMO) {
                    interval = MonthOffsetIntervalMO(context: moc)
                    act.interval = interval
                }
            case .Year:
                if !(interval is YearOffsetIntervalMO) {
                    interval = YearOffsetIntervalMO(context: moc)
                    act.interval = interval
                }
            }
            (interval as! OffsetIntervalMO).offset = Int16(scale)
            
        default:
            break
        }
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if setSelectedRow(row: TableRows.ByDay) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        return true
    }
    
}

// MARK: WeekDayPickerDelegate
extension ChooseIntervalTableViewController : WeekDayPickerDelegate {
    
    func weekdaySet(day:Int, symbol:String) {
        byWeekdayLabel.text! = symbol // TODO: Update the interval
    }
    
}
// MARK: ByMonthDayPickerDelegate
extension ChooseIntervalTableViewController : MonthDayPickerDelegate {
    
    func monthDaySet(_ day: Int, formattedValue: String) {
        byMonthDayLabel.text! = formattedValue
    }

}
// MARK: ByYearDayPickerDelegate
extension ChooseIntervalTableViewController : YearDayPickerDelegate {
    
    func yearDaySet(month: Int, monthSymbol:String, day: Int) {
        byYearDayLabel.text = monthSymbol + " " + String(day) // TODO: Update the interval
    }

}

extension ChooseIntervalTableViewController : ScaleDateComponentPickerDelegate {
    
    func scaleComponentsSet(component: OffsetIntervals, scale: Int) {
        // TODO:
        switch component {
        case .Week:
            byDateComponentLabel.text = (scale == 1) ? "Week" : String(scale) + " Weeks"
        case .Month:
            byDateComponentLabel.text = (scale == 1) ? "Month" : String(scale) + " Months"
        case .Year:
            byDateComponentLabel.text = (scale == 1) ? "Year" : String(scale) + " Years"
        }

    }
    
}

// MARK: Private functions
extension ChooseIntervalTableViewController {
    
    private func configureWheneverTableViewCell(interval:IntervalMO) {
        if interval is UnlimitedIntervalMO {
            wheneverTableViewCell.accessoryType = .checkmark
            currentSelectedRow = .Whenever
        } else {
            wheneverTableViewCell.accessoryType = .none
        }
    }

    private func configureConstantTableViewCell(interval:IntervalMO) {
        if interval is ConstantIntervalMO {
            let constantInterval = interval as! ConstantIntervalMO
            byDayTableViewCell.accessoryType = .checkmark
            byDayTextField.text = String(constantInterval.frequency)
            currentSelectedRow = .ByDay
        } else {
            byDayTableViewCell.accessoryType = .none
        }
    }

}

