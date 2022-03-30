//
//  ViewController.swift
//  LensReceiptsDemo
//
//  Created by Diego Giraldo on 24/03/22.
//

import UIKit
import VeryfiLens

class ViewController: UIViewController {
    @IBOutlet weak var logsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let CLIENT_ID = "XXX" // replace XXX with your assigned Client Id
        let AUTH_USERNAME = "XXX" // replace XXX with your assigned Username
        let AUTH_APIKEY = "XXX" // replace XXX with your assigned API Key
        let URL = "XXX" // replace XXX with your assigned Endpoint URL

        let credentials = VeryfiLensCredentials(clientId: CLIENT_ID,
                                                          username: AUTH_USERNAME,
                                                          apiKey: AUTH_APIKEY,
                                                          url: URL)
        let settings = VeryfiLensSettings()
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
}

extension ViewController: VeryfiLensDelegate {
    func veryfiLensClose(_ json: [String : Any]!) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensError(_ json: [String : Any]!) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensSuccess(_ json: [String : Any]!) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensUpdate(_ json: [String : Any]!) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
}

