//
//  ViewController.swift
//  LensReceiptsDemo
//
//  Created by Diego Giraldo on 24/03/22.
//

import UIKit
import VeryfiLens

class LogsViewController: UIViewController {
    @IBOutlet weak var logsTextView: UITextView!
    
    var jsonSettings: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lens Logs"
        
        let CLIENT_ID = getEnvironmentVar(key: "VERYFI_CLIENT_ID") // replace with your assigned Client Id
        let AUTH_USERNAME = getEnvironmentVar(key: "VERYFI_USERNAME") // replace with your assigned Username
        let AUTH_APIKEY = getEnvironmentVar(key: "VERYFI_API_KEY") // replace with your assigned API Key
        let URL = getEnvironmentVar(key: "VERYFI_URL") // replace with your assigned Endpoint URL

        let credentials = VeryfiLensCredentials(clientId: CLIENT_ID,
                                                          username: AUTH_USERNAME,
                                                          apiKey: AUTH_APIKEY,
                                                          url: URL)
        let settings = VeryfiLensSettings(with: jsonSettings)
        // Specific document types for this demo (VeryfiLens-Receipts)
        settings.documentTypes = ["receipt", "bill"]
        settings.showDocumentTypes = true
        
        VeryfiLens.shared().delegate = self
        
        VeryfiLens.shared().configure(with: credentials, settings: settings)
    }


    @IBAction func launchLens(_ sender: Any) {
        VeryfiLens.shared().showCamera(in: self)
    }
    
    func string(from json: [String : Any]) -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
        return String(data: jsonData!, encoding: .utf8)
    }
    
    //Func to get environment variables.
    func getEnvironmentVar(key: String) -> String {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
}

extension LogsViewController: VeryfiLensDelegate {
    func veryfiLensClose(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensError(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensSuccess(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensUpdate(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
}

