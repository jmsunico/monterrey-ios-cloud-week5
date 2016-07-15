//
//  DetailsViewController.swift
//  openLibrary3
//
//  Created by José-María Súnico on 20160713.
//  Copyright © 2016 José-María Súnico. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
	var index : Int = -1
	
	@IBOutlet weak var isbnLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorsLabel: UILabel!

	
	@IBOutlet weak var coverImage: UIImageView!
	
	
	@IBAction func returnButton(sender: UIBarButtonItem) {
		print("pressed return button on detailsView")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		print("Showing details of row: ", self.index)
		
		self.isbnLabel.text = "ISBN:\t" + (myBooks[self.index].valueForKey("isbn") as? String)!
		self.titleLabel.text = "Título:\t" + (myBooks[self.index].valueForKey("title") as? String)!
		self.authorsLabel.text = "Autor(es):\t" + (myBooks[self.index].valueForKey("authors") as? String)!
		self.coverImage.image = UIImage(data: (myBooks[self.index].valueForKey("cover") as? NSData)!)
	}
}
