//
//  SSUCalendarEventDetailController.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/1/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import EventKitUI

class SSUCalendarEventDetailController: UITableViewController, EKEventEditViewDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionWebView: UIWebView!
    
    var event: SSUEvent!
    
    func updateDisplay() {
        titleLabel.text = event.title
        categoryLabel.text = event.category;
        if let location = event.location {
            locationLabel.text = (location as NSString).decodingXMLEntities()
        } else {
            locationLabel.text = "No location provided"
        }
        
        if let startDate = event.startDate {
            dateLabel.text = DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .short)
        } else {
            dateLabel.text = nil
        }
        
        if let summary = event.summary {
            descriptionWebView.loadHTMLString(summary, baseURL: nil)
        } else {
            descriptionWebView.loadHTMLString("No description for this event", baseURL: nil)
        }
    }
    
    @IBAction
    func addToCalendarAction(_ sender: Any) {
        let eventVc = EKEventEditViewController()
        eventVc.editViewDelegate = self;
        
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        
        eventVc.eventStore = eventStore
        eventVc.event = event
        
        eventStore.requestAccess(to: EKEntityType.event) { (granted, error) in
            if !granted {
                let alert = UIAlertController(title: "Calendar Access Denied", message: "To add SSU events to your calendar, grant SSUMobile access to the calendar in your device's settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.present(eventVc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: EKEventEditViewDelegate
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        self.dismiss(animated: true, completion: nil)
    }
}
