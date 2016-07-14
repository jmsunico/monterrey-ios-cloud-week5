//
//  DetailsViewController.swift
//  openLibrary3
//
//  Created by José-María Súnico on 20160713.
//  Copyright © 2016 José-María Súnico. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
	var sectionIndex = -1
	
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
		
		print("Showing details of row: ", self.sectionIndex)
		print(sections[self.sectionIndex])
		
		self.isbnLabel.text = (sections[self.sectionIndex]).isbn
		self.titleLabel.text = (sections[self.sectionIndex]).title
		self.authorsLabel.text = (sections[self.sectionIndex]).authors
		self.coverImage.image = (sections[self.sectionIndex]).cover
    }
}
