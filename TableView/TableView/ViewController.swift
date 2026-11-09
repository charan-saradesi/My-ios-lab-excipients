//
//  ViewController.swift
//  TableView
//
//  Created by shiro on 06/02/26.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableview1 : UITableView!
    var Array1: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        Array1=["Ashok","Bhaskr","Chaitra"]
        tableview1.delegate=self
        tableview1.dataSource=self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array1.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell=tableView.dequeueReusableCell(withIdentifier: "identifier1", for: indexPath)
        cell.textLabel?.text=Array1[indexPath.row]
        cell.backgroundColor = .yellow
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedName=Array1[indexPath.row]
        print("You selected cell #\(selectedName)!")
        
        let alert = UIAlertController(
            title: "you clicked", message: selectedName, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert,animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}




