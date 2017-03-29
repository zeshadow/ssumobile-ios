//
//  SSUAboutViewController.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/25/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

class SSUAboutViewController: UITableViewController {
    
    struct ReuseIdentifier {
        static let legal = "Legal"
        static let ldap = "LDAP"
        static let cache = "Cache"
        static let feedback = "Feedback"
    }
    
    private let cacheFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useMB
        formatter.countStyle = .file
        formatter.allowsNonnumericFormatting = false
        return formatter
    }()
    
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var imageCacheLabel: UILabel!
    @IBOutlet var ldapLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        updateCacheDisplay()
        updateLDAPDisplay()
    }
    
    private func updateCacheDisplay() {
        ImageCache.default.calculateDiskCacheSize { (bytes) in
            let mb = self.cacheFormatter.string(fromByteCount: Int64(bytes))
            self.imageCacheLabel.text = "Cached images: \(mb)"
        }
    }
    
    private func updateLDAPDisplay() {
        ldapLabel.isEnabled = SSULDAPCredentials.sharedInstance().hasCredentials
    }
    
    // MARK: UITableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath), let identifier = cell.reuseIdentifier else {
            SSULogging.logError("Unable to retrieve selected cell in AboutViewController")
            return
        }
        switch identifier {
        case ReuseIdentifier.legal:
            if let fileURL = Bundle.main.url(forResource: "licenses", withExtension: "txt") {
                let webVc = SSUWebViewController()
                webVc.urlToLoad = fileURL
                self.navigationController?.pushViewController(webVc, animated: true)
            }
        case ReuseIdentifier.ldap:
            if SSULDAPCredentials.sharedInstance().hasCredentials {
                SSULDAPCredentials.sharedInstance().clear()
                updateLDAPDisplay()
                let hud = MBProgressHUD.showAdded(to: tableView, animated: true)
                hud.label.text = "Logged Out"
                hud.mode = .text
                hud.hide(animated: true, afterDelay: 1.0)
            }
        case ReuseIdentifier.cache:
            let hud = MBProgressHUD.showAdded(to: tableView, animated: true)
            hud.label.text = "Clearing cache..."
            hud.mode = .annularDeterminate
            ImageCache.default.clearDiskCache(completion: { 
                hud.label.text = "Cache cleared"
                hud.mode = .text
                hud.hide(animated: true, afterDelay: 1.0)
                self.updateCacheDisplay()
            })
        case ReuseIdentifier.feedback:
            // Handled by storyboard
            break
        default:
            SSULogging.logError("Unrecognized cell identifier \(identifier)")
        }
    }
    
}
