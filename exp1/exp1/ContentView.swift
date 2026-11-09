//
//  ContentView.swift
//  exp1
//
//  Created by shiro on 03/09/25.
//

import SwiftUI

//
//  ViewController.swift
//  StudentDetailsApp
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets
    // These connect to the UI elements in your storyboard.
    @IBOutlet var t1: UITextField! // For the first detail (e.g., Name)
    @IBOutlet var t2: UITextField! // For the second detail (e.g., Student ID)
    @IBOutlet var t3: UITextField! // For the third detail (e.g., Major)
    @IBOutlet var t4: UITextField! // For the fourth detail (e.g., Year)
    @IBOutlet var t5: UITextField! // For the fifth detail (e.g., GPA)
    
    @IBOutlet var b1: UIButton! // The submit button

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // This method is called when the view first loads.
        // You can add initial setup code here, like styling the button.
        setupUI()
    }
    
    // A helper function to keep viewDidLoad clean.
    func setupUI() {
        // Example: Give the button rounded corners
        b1.layer.cornerRadius = 8
    }

    // MARK: - IBActions
    // This function is called when the button is tapped.
    @IBAction func b1Onclick(_ sender: UIButton) {
        // Safely unwrap the text from each text field.
        // If a text field is nil, it will use an empty string "".
        let detail1 = t1.text ?? ""
        let detail2 = t2.text ?? ""
        let detail3 = t3.text ?? ""
        let detail4 = t4.text ?? ""
        let detail5 = t5.text ?? ""
        
        // Print the details to the debug console in Xcode.
        // The triple quotes """ allow for a multi-line string.
        print("""
        -------------------------
        Student Details Received:
        1: \(detail1)
        2: \(detail2)
        3: \(detail3)
        4: \(detail4)
        5: \(detail5)
        -------------------------
        """)
    }
}

#Preview {
    ContentView()
}
