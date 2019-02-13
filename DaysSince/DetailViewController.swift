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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSummary" {
            print("Embedding")
            summaryViewController = segue.destination as? ActivitySummaryViewController
            if let summaryVC = summaryViewController {
                summaryVC.activity = detailItem
            }
        }
    }

    var detailItem: ActivityMO? {
        didSet {
            // Update the view.
            configureView()
            if let summaryVC = summaryViewController {
                summaryVC.activity = detailItem
            }
        }
    }

    @objc
    func selectionDidChange(_ sender: UISegmentedControl) {
        print("Button changed: \(segmentedControl.selectedSegmentIndex)")
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
        
        self.addChild(viewController)
        return viewController
    }()
}

