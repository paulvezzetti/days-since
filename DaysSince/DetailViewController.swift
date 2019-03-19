//
//  DetailViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet var alternatingView: UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var markDoneButton: UIButton!
    
    var dataManager: DataModelManager? = nil
    
    var detailItem: ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityChanged(notification:)), name: Notification.Name.activityChanged, object: detailItem)

            // Update the view.
            configureView()
            if let summaryVC = summaryViewController {
                summaryVC.activity = detailItem
            }
        }
    }

    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try dataManager?.saveContext()
        } catch {
            // TODO: Alert of save failure
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSummary" {
            summaryViewController = segue.destination as? ActivitySummaryViewController
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
            // TODO: When we return, we need to refresh the view
        }
    }
    
    @IBAction func unwindSaveActivity(segue: UIStoryboardSegue) {
        
        do {
            try dataManager?.saveContext()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        configureView()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "Delete this activity?", message: "This will permanently delete this activity and all of its history.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { (alert) in
            self.deleteActivity()
        })
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc
    func onActivityChanged(notification:Notification) {
        configureView()
    }

    
    func deleteActivity() {
        guard let activity = detailItem else {
            return
        }
        if let dm = dataManager {
            do {
                try dm.removeActivity(activity: activity)
            } catch {
                // TODO: This should show an error screen.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


    @objc
    func selectionDidChange(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            // Remove the history
            historyViewController.willMove(toParent: nil)
            historyViewController.view.removeFromSuperview()
            historyViewController.removeFromParent()
            // Restore the summary
            if let summaryVC = summaryViewController {
                addChild(summaryVC)
                alternatingView.addSubview(summaryVC.view)
                summaryVC.view.frame = alternatingView.bounds
                summaryVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                summaryVC.didMove(toParent: self)
            }
            
            
        } else {
           // Remove the summary
            if let summaryVC = summaryViewController {
                summaryVC.willMove(toParent: nil)
                summaryVC.view.removeFromSuperview()
                summaryVC.removeFromParent()
            }
            //Restore the history
            addChild(historyViewController)
            alternatingView.addSubview(historyViewController.view)
            historyViewController.view.frame = alternatingView.bounds
            historyViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            historyViewController.didMove(toParent: self)
        }
    }
    
    private var summaryViewController:ActivitySummaryViewController?
    
    private lazy var historyViewController: HistoryTableViewController = {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "HistoryTableViewController") as! HistoryTableViewController
        viewController.activity = detailItem
        viewController.dataManager = dataManager
        
        self.addChild(viewController)
        return viewController
    }()
}

extension DetailViewController : MarkDoneDelegate {
    
    func complete(sender: UIViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}
