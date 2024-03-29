//
//  DetailViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet var alternatingView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var bottomToolbar: UIToolbar!
    
    // MARK: - Public variables
    var dataManager: DataModelManager? = nil {
        didSet {
            if dataManager != nil && isViewLoaded {
                configureView()
            }
            if let activeSubVC = activeSubViewController {
                setViewControllerProperties(activeSubVC)
            }
        }
    }
    
    var detailItem: ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityAdded(notification:)), name: Notification.Name.activityAdded, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityChanged(notification:)), name: Notification.Name.activityChanged, object: detailItem)
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityRemoved(notification:)), name: Notification.Name.activityRemoved, object: detailItem)

            // Update the view.
            configureView()
            if let summaryVC = summaryViewController {
                summaryVC.activity = detailItem
            }
            if let activeSubVC = activeSubViewController {
                setViewControllerProperties(activeSubVC)
            }
        }
    }

    // MARK: - Private variables
    private var activeSubViewController: UIViewController?

    private var summaryViewController:ActivitySummaryTableViewController?
    
    private lazy var historyViewController: HistoryTableViewController = {
        return createViewController(withIdentifier: "HistoryTableViewController") as! HistoryTableViewController
    }()
    
    
    private lazy var settingsViewController: ActivityInfoTableViewController = {
        return createViewController(withIdentifier: "ActivityInfoTableViewController") as! ActivityInfoTableViewController
    }()
    
    
    private lazy var noActivityViewController: BlankActivityTableViewController = {
        return createViewController(withIdentifier: "BlankActivityTableViewController") as! BlankActivityTableViewController
    }()


    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onActivityAdded(notification:)), name: Notification.Name.activityAdded, object: nil)

        activeSubViewController = summaryViewController
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try dataManager?.saveContext()
        } catch {
            let nserror = error as NSError
            let alert = UIAlertController(title: NSLocalizedString("saveActivity.error.title", value: "Error saving activity", comment: ""),message: NSLocalizedString("deleteActivity.error.msg", value: "An error occurred while attempting to save the activity. If this continues, please kill the application and retry. The error was: \n\(nserror.localizedDescription)", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSummary" {
            summaryViewController = segue.destination as? ActivitySummaryTableViewController
            if let summaryVC = summaryViewController {
                summaryVC.activity = detailItem
            }
        } else if segue.identifier == "markDoneSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! MarkDoneTableViewController
            controller.doneDelegate = self
            controller.activity = detailItem
            controller.dataManager = dataManager
        } else if segue.identifier == "editActivity" {
            let controller = segue.destination as! AddActivityTableViewController
            controller.dataManager = dataManager
            controller.editActivity = detailItem
        }
    }

    // MARK: - IBActions
    
    @IBAction func markDoneFromToolbar(_ sender: Any) {
        self.performSegue(withIdentifier: "markDoneSegue", sender: self)
    }
    
    @IBAction func snoozeFromToolbar(_ sender: Any) {
        guard let reminder = detailItem?.reminder, reminder.allowSnooze else {

            let alertNoSnooze = UIAlertController(title: NSLocalizedString("snooze", value: "Snooze", comment: ""), message: NSLocalizedString("snoozeNotEnabled.msg", value: "This activity is not enabled for snooze. You must edit this activity and enable snooze first.", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alertNoSnooze.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: nil))
            self.present(alertNoSnooze, animated: true, completion: nil)

            return
        }
        let alert = UIAlertController(title: NSLocalizedString("snooze", value: "Snooze", comment: ""), message: NSLocalizedString("snooze.alert", value:"Enter a number of days to snooze or select the default.", comment: ""), preferredStyle: UIAlertController.Style.alert)
        // Add a text field where the user can enter the number of days to snooze
        alert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("snoozeAmount.prompt.txt", value: "Snooze amount in days", comment: "")
            textField.keyboardType = UIKeyboardType.numberPad
        })
        // First action is to snooze using the number that was entered.
        alert.addAction(UIAlertAction(title: NSLocalizedString("snooze", value: "Snooze", comment: ""), style: .default) { (action) in

            var daysToSnooze:Int = -1
            if let textField = alert.textFields?.first, let text = textField.text {
                daysToSnooze = Int(text) ?? -1
            }
            NotificationCenter.default.post(name: .snoozeActivity, object: self.detailItem, userInfo: ["days": daysToSnooze])
        })
        // Second action is default snooze
        alert.addAction(UIAlertAction(title: String.localizedStringWithFormat(NSLocalizedString("numDays.label.string", comment: ""), Int(reminder.snooze)), style: .default) { (action) in
            NotificationCenter.default.post(name: .snoozeActivity, object: self.detailItem)
        })
        // Third action is cancel
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", value: "Cancel", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func unwindSaveActivity(segue: UIStoryboardSegue) {
        configureView()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("deleteActivity.title", value: "Delete this activity?", comment: "Title used for prompt when deleting activity"), message: NSLocalizedString("deleteActivity.msg", value: "This will permanently delete this activity and all of its history.", comment: "Message used for prompt when deleting activity"), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", value: "Delete", comment: ""), style: .destructive) { (alert) in
            self.deleteActivity()
            self.navigationController?.navigationController?.popToRootViewController(animated: false)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", value: "Cancel", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Private extension
extension DetailViewController {
    
    private func createViewController(withIdentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: withIdentifier)
        
        setViewControllerProperties(viewController);

        self.addChild(viewController)
        return viewController
    }
    
    private func setViewControllerProperties(_ viewController: UIViewController) {
        if var activityBasedController = viewController as? ActivityBased {
            activityBasedController.activity = detailItem
        }
        if var dataManagerController = viewController as? DataModelManagerRequired {
            dataManagerController.dataManager = dataManager
        }
    }
    
    private func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.name
            }
            if let segControl = segmentedControl {
                segControl.isHidden = false
            }
            if let toolbar = bottomToolbar {
                toolbar.isHidden = false
            }
            if let activeViewController = self.activeSubViewController {
                if activeSubViewController == noActivityViewController {
                    removeChildFromSubview(viewController: activeViewController)
                    
                    if let summaryVC = summaryViewController {
                        summaryVC.activity = detailItem
                        addChildToSubview(viewController: summaryVC)
                    }
                    
                }
            }
        } else {
            if let label = detailDescriptionLabel {
                label.text = ""
            }
            if let segControl = segmentedControl {
                segControl.isHidden = true
            }
            if let toolbar = bottomToolbar {
                toolbar.isHidden = true
            }
            
            if let activeViewController = self.activeSubViewController {
                removeChildFromSubview(viewController: activeViewController)
            }
            addChildToSubview(viewController: noActivityViewController)
        }
    }

    func deleteActivity() {
        guard let activity = detailItem else {
            return
        }
        if let dm = dataManager {
            do {
                try dm.removeActivity(activity: activity)
            } catch {
                let nserror = error as NSError
                let alert = UIAlertController(title: NSLocalizedString("deleteActivity.error.title", value: "Error deleting activity", comment: ""), message: NSLocalizedString("deleteActivity.error.msg", value: "An error occurred while attempting to delete the activity. If this continues, please kill the application and retry. The error was: \n\(nserror.localizedDescription)", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    // Handles added a new child to the alternating subview
    private func addChildToSubview(viewController: UIViewController) {
        addChild(viewController)
        alternatingView.addSubview(viewController.view)
        viewController.view.frame = alternatingView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
        activeSubViewController = viewController
    }

    // Handles removing a child to the alternating subview
    private func removeChildFromSubview(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    // MARK: - Observers
    @objc
    func onActivityAdded(notification:Notification) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        if activity != detailItem {
            detailItem = activity
        }
    }
    
    @objc
    func onActivityChanged(notification:Notification) {
        configureView()
    }
    
    @objc
    func onActivityRemoved(notification:Notification) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        if activity === detailItem {
            detailItem = nil
        }
    }
    
    @objc
    func selectionDidChange(_ sender: UISegmentedControl) {
        if let activeViewController = self.activeSubViewController {
            removeChildFromSubview(viewController: activeViewController)
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Restore the summary
            if let summaryVC = summaryViewController {
                addChildToSubview(viewController: summaryVC)
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            //Restore the history
            addChildToSubview(viewController: historyViewController)
        } else if segmentedControl.selectedSegmentIndex == 2 {
            addChildToSubview(viewController: settingsViewController)
        }
    }
    
}

// MARK: - MarkDoneDelegate

extension DetailViewController : MarkDoneDelegate {
    
    func complete(sender: UIViewController) {
        sender.dismiss(animated: false, completion: nil)
        sender.navigationController!.popViewController(animated: false)
    }

}
