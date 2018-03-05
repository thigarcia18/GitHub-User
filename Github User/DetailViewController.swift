//
//  DetailViewController.swift
//  AgileContent Exercise
//
//  Created by Thiago Garcia on 22/02/18.
//  Copyright © 2018 iGarcia. All rights reserved.
//

import UIKit

// MARK: - Global properties
public var reposFromJSON = [[String: String]]()
public var userImage = ""

class DetailViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var spaceView: UIView!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageAndLabel()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            userImage = ""
            reposFromJSON.removeAll(keepingCapacity: true)
        }
    }
    
    // MARK: - TableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reposFromJSON.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let repo = reposFromJSON[indexPath.row]
        cell.textLabel?.text = repo["name"]
        cell.detailTextLabel?.text = repo["language"]
        return cell
    }
    
    // MARK: - Helper methods
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    private func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    private func setImageAndLabel() {
        if userImage == "" {
            imageView.isHidden = true
        } else {
            imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
            if let url = URL(string: userImage) {
                downloadImage(url: url)
            }
        }
        label.text = gitHubUser
    }
}

