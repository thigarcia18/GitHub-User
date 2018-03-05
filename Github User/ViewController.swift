//
//  ViewController.swift
//  Github User
//
//  Created by Thiago Garcia on 05/03/18.
//  Copyright © 2018 iGarcia. All rights reserved.
//

import UIKit

// MARK: - Global properties
public var gitHubUser = ""

class ViewController: UIViewController {
    // MARK: - Properties
    private var errorType = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    
    
    // MARK: - IBActions
    @IBAction private func searchButtonTapped(_ sender: Any) {
        if let stringUser = searchTextField.text {
            gitHubUser = stringUser
            performSelector(inBackground: #selector(downloadJSON), with: nil)
        }
    }
    
    // MARK: - Helper methods
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    @objc private func downloadJSON() {
        guard let urlString = URL(string: "https://api.github.com/users/" + gitHubUser + "/repos") else { return }
        getDataFromUrl(url: urlString) { data, response, error in
            if error != nil {
                self.errorType = 1
                self.performSelector(onMainThread: #selector(self.showError), with: nil, waitUntilDone: false)
                return
            }
            guard let responseCode = response?.getStatusCode() else { return }
            if responseCode == 404 {
                self.errorType = 2
                self.performSelector(onMainThread: #selector(self.showError), with: nil, waitUntilDone: false)
                return
            } else {
                if let data = try? String(contentsOf: urlString) {
                    let json = JSON(parseJSON: data)
                    self.parse(json: json)
                    return
                }
            }
        }
    }
    
    private func parse(json: JSON) {
        for result in json.arrayValue {
            let name = result["name"].stringValue
            let language = result["language"].stringValue
            if userImage == "" {
                userImage = result["owner"]["avatar_url"].stringValue
            }
            let obj = ["name": name, "language": language]
            reposFromJSON.append(obj)
        }
        performSelector(onMainThread: #selector(activeSegue), with: nil, waitUntilDone: false)
    }
    
    @objc private func showError() {
        var title = ""
        var message = ""
        switch errorType {
        case 1:
            title = "Loading error"
            message = "A network error has occured. Check your connection and try again later."
        case 2:
            title = "User not found"
            message = "Please enter another name."
        default: break
        }
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - Navigation
    @objc private func activeSegue() {
        performSegue(withIdentifier: "mySegue", sender: self)
    }
    
}

// MARK: - Extensions
extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

