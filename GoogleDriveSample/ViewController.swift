//
//  ViewController.swift
//  GoogleDriveSample
//
//  Created by Tadashi on 2017/01/25.
//  Copyright © 2017 T@d. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {

	@IBOutlet var didTapSinginButton: UIButton!
    @IBAction func didTapSinginButton(_ sender: AnyObject) {

		if GIDSignIn.sharedInstance().currentUser?.authentication.accessToken == nil {
			GIDSignIn.sharedInstance().signIn()
		} else {
			GIDSignIn.sharedInstance().disconnect()
		}
    }

	@IBOutlet var didTapFetchButton: UIButton!
    @IBAction func didTapFetchButton(_ sender: AnyObject) {

		let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ListView") as! ListView
		vc.parentItem = nil
		self.navigationItem.title = ""
		self.navigationController?.pushViewController(vc, animated: true)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.didTapFetchButton.layer.borderWidth = 0.5
		self.didTapSinginButton.layer.borderWidth = 0.5
		self.didTapFetchButton.layer.cornerRadius = 4.0
		self.didTapSinginButton.layer.cornerRadius = 4.0
		self.didTapFetchButton.layer.borderColor = UIColor.lightGray.cgColor
		self.didTapSinginButton.layer.borderColor = UIColor.lightGray.cgColor

		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/drive"]
		GIDSignIn.sharedInstance().shouldFetchBasicProfile = false

        NotificationCenter.default.addObserver(self,
			selector: #selector(didSignIn(notification:)),
			name: NSNotification.Name(rawValue: "didSignIn"),
			object: nil)

        NotificationCenter.default.addObserver(self,
			selector: #selector(didDisconnect(notification:)),
			name: NSNotification.Name(rawValue: "didDisconnect"),
			object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.changeSignInButton()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// Invoked when Sign in successfully completed.
	func didSignIn(notification: Notification) {
		self.changeSignInButton()
	}

	// Invoked when disconnect successfully completed.
	func didDisconnect(notification: Notification) {
		self.changeSignInButton()
	}

	func changeSignInButton() {
	
		if GIDSignIn.sharedInstance().currentUser?.authentication.accessToken != nil {
			self.didTapSinginButton.setTitle("Sign Out", for: .normal)
			self.didTapFetchButton.isEnabled = true
		} else {
			if GIDSignIn.sharedInstance().hasAuthInKeychain() {
				GIDSignIn.sharedInstance().signIn()
			} else {
				self.didTapSinginButton.setTitle("Sign In", for: .normal)
				self.didTapFetchButton.isEnabled = false
			}
		}
	}

	// Present a view that prompts the user to sign in with Google
	func sign(_ signIn: GIDSignIn!,
			present viewController: UIViewController!) {
		self.present(viewController, animated: true, completion: nil)
	}

	// Dismiss the "Sign in with Google" view
	func sign(_ signIn: GIDSignIn!,
	          dismiss viewController: UIViewController!) {
		self.dismiss(animated: true, completion: nil)
	}
}
