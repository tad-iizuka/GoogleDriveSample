//
//  ListView.swift
//  GoogleDriveSample
//
//  Created by Tadashi on 2017/01/26.
//  Copyright © 2017 T@d. All rights reserved.
//

import UIKit

class ListView: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var alert : UIAlertController!
	var items : JSON! = []
	var parentItem : JSON!

	@IBOutlet var tableView: UITableView!

	func getRootDirestoryList(value: String) {

        let token = GIDSignIn.sharedInstance().currentUser?.authentication.accessToken!

		let searchWord = "'\(value)' in parents".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		let url = "https://www.googleapis.com/drive/v2/files?maxresults=1000&orderBy=folder,title&q=\(searchWord!)"
		var request = URLRequest.init(url: URL(string: url)!)
		let authValue : NSString = NSString(format: "Bearer %@", token!)
		request.setValue(authValue as String, forHTTPHeaderField: "Authorization")
		
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
			do {
				let dic = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! NSDictionary
				let result = JSON(dic)
				self.items = result["items"]
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			} catch {
				print(error)
			}
        })
        task.resume()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
	
		super.viewWillAppear(animated)

		var id = "root"
		if self.parentItem != nil {
			id = self.parentItem["id"].string!
		}
		self.getRootDirestoryList(value: id)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}

	func numberOfSections(in tableView: UITableView) -> Int {

		return	1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return	self.items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let item  = items[indexPath.row]
		cell.textLabel?.text = item["title"].string
		cell.detailTextLabel?.text = ISO8601ToLocale(dateString: item["modifiedByMeDate"].string!)

		if item["mimeType"].string! == "application/vnd.google-apps.folder" {
			cell.imageView?.image = UIImage.init(named: "Folder-50.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			cell.imageView?.tintColor = UIColor.darkGray
			cell.textLabel?.textColor = UIColor.darkGray
			cell.detailTextLabel?.textColor = UIColor.darkGray
		} else {
			cell.imageView?.image = nil
			cell.textLabel?.textColor = UIColor.black
			cell.detailTextLabel?.textColor = UIColor.black
		}

		return cell
	}

	func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {

		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let item  = items[indexPath.row]
		if item["mimeType"].string! == "application/vnd.google-apps.folder" {
			let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ListView") as! ListView
			vc.parentItem = item
			self.navigationItem.title = ""
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

	func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
	}

	func ISO8601ToLocale(dateString: String) -> String {

		let form = DateFormatter()
		form.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		form.timeZone = TimeZone.init(abbreviation: "UTC")
		let date = form.date(from: dateString)
		let form1 = DateFormatter()
		form1.dateFormat = "yyyy/MM/dd HH:mm:ss"
		return	form1.string(from: date!)
	}
	
//	func showIndicator(value: Bool) {
//	
//		print(value)
//
//		if value {
//
//			if alert == nil {
//				self.alert = UIAlertController.init(title: nil, message: "Accessing...", preferredStyle: .alert)
//			}
//
//			let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//			indicator.center = CGPoint(x: 25, y: 30)
//			self.alert.view.addSubview(indicator)
//		
//			DispatchQueue.main.async {
//				indicator.startAnimating()
//				self.present(self.alert, animated: true, completion: nil)
//			}
//		} else {
//
//			if self.alert != nil {
//				DispatchQueue.main.async {
//					self.alert!.dismiss(animated: false, completion: nil)
//					self.alert = nil
//				}
//			}
//		}
//	}
}
