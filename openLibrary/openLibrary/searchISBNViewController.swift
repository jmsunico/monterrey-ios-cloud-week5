//
//  searchISBNViewController.swift
//  openLibrary3
//
//  Created by José-María Súnico on 20160713.
//  Copyright © 2016 José-María Súnico. All rights reserved.
//

import UIKit

class SearchISBNViewController: UIViewController {

	var newSection = Section(isbn: "")
	
	func gotThat(isbn: String) -> Bool{
		for index in 0..<sections.count{
			if isbn == sections[index].isbn{
				return true
			}
		}
		return false
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		print("TextField should return method called")
		textField.resignFirstResponder()
		return true
	}
	
	@IBAction func editingEnd(sender: AnyObject) {
		self.resignFirstResponder()
	}
	@IBAction func searchTextField(sender: UITextField) {
		var newISBN : String? = sender.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		if (newISBN != nil) && (newISBN! != ""){
			if newISBN == "test1"{
				newISBN = "978-84-376-0494-7"
			}
			else if newISBN == "test2"{
				newISBN = "978-84-973-6467-6"
			}
			
			if gotThat(newISBN!){
				let alert = UIAlertController(title: "ERRORS!", message: "Ya lo tenemos!!!",	preferredStyle: .Alert)
				let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alert.addAction(accion)
				self.presentViewController(alert, animated: true, completion: nil)
			} else{
				newSection = searchISBN(newISBN!)
				if (newSection.errors == ""){
					self.isbnLabel.text = "ISBN: " + newSection.isbn
					self.titleLabel.text = "TÍTULO: " + newSection.title
					self.authorsLabel.text = "AUTOR(ES): " + newSection.authors
					self.coverImage.image = newSection.cover
				}
				else{
					//Report ERRORS!!!
					let alert = UIAlertController(title: "ERRORS!", message: newSection.errors,	preferredStyle: .Alert)
					let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alert.addAction(accion)
					self.presentViewController(alert, animated: true, completion: nil)
				}
			}
		}
	}

	func searchISBN(realISBN: String) -> Section{
		var newSection = Section(isbn: realISBN)
		
		let query = String("https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + newSection.isbn)
		let myQuery = NSURL(string: query)
		if myQuery == nil{
			newSection.errors = "NO VALID QUERY!"
			return newSection
		}
		
		let jsonAnswer: AnyObject?
		do{ //trying to process response
			let theirResponse = NSData(contentsOfURL: myQuery!)
			if theirResponse == nil {
				throw NSURLError.BadServerResponse
			}
			jsonAnswer = try NSJSONSerialization.JSONObjectWithData((theirResponse)!, options: NSJSONReadingOptions.MutableLeaves)
		}
		catch _{
			newSection.errors = "NO INTERNET CONNECTION!"
			return newSection
		}
		
		let dictAnswer = jsonAnswer as? NSDictionary
		if dictAnswer == nil {
			newSection.errors = "NO VALID ANSWER RECEIVED!"
			return newSection
		}
		
		let dictISBN = dictAnswer!["ISBN:" + newSection.isbn] as? NSDictionary
		if dictISBN == nil {
			newSection.errors = "NO VALID ISBN FIELD!"
			return newSection
		}
		
		let dictISBN_title = dictISBN!["title"] as? String
		if dictISBN_title == nil {
			newSection.errors = "NO TITLE FOUND!"
			return newSection
		} else{
			newSection.title = dictISBN_title!
		}
		
		let dictISBN_cover = dictISBN!["cover"] as? NSDictionary
		if dictISBN_cover != nil{
			let smallCoverString = dictISBN_cover!["small"] as? String
			let mediumCoverString = dictISBN_cover!["medium"] as? String
			let largeCoverString = dictISBN_cover!["large"] as? String
			if largeCoverString != nil {
				let coverURL = NSURL(string: largeCoverString!)
				let coverDATA = NSData(contentsOfURL: coverURL!)
				if coverDATA != nil{
					if let coverImage = UIImage(data: coverDATA!){
						newSection.cover = coverImage
					}
				}
			}
			else if mediumCoverString != nil {
				let coverURL = NSURL(string: mediumCoverString!)
				let coverDATA = NSData(contentsOfURL: coverURL!)
				if coverDATA != nil{
					if let coverImage = UIImage(data: coverDATA!){
						newSection.cover = coverImage
					}
				}
			}
			else if smallCoverString != nil {
				let coverURL = NSURL(string: smallCoverString!)
				let coverDATA = NSData(contentsOfURL: coverURL!)
				if coverDATA != nil{
					if let coverImage = UIImage(data: coverDATA!){
						newSection.cover = coverImage
					}
				}
			}
			else {
				newSection.errors = "WE SHOULD NEVER BE HERE!"
				return newSection
			}
		}
		
		let dictISBN_yearpub = dictISBN!["publish_date"] as? String
		if dictISBN_yearpub != nil {
			newSection.pubdate = dictISBN_yearpub!
		}
		
		let dictISBN_url = dictISBN!["url"] as? String
		if dictISBN_url != nil {
			newSection.url = dictISBN_url!
		}
		
		let arrayAuthors = dictISBN!["authors"] as? NSArray
		if arrayAuthors != nil {
			var authors = ""
			for index in 0..<arrayAuthors!.count{
				let tempDict = arrayAuthors![index] as! NSDictionary
				authors = authors + (tempDict["name"] as! String) + " ("
				authors = authors + (tempDict["url"] as! String) + ")\n"
			}
			newSection.authors = authors // may be change into an array if needed...
		}
		
		let arraySubjects = dictISBN!["subjects"] as? NSArray
		if arraySubjects != nil{
			var keywords = ""
			for index in 0..<arraySubjects!.count{
				let tempDict = arraySubjects![index] as! NSDictionary
				keywords = keywords + (tempDict["name"] as! String) + " "
			}
			newSection.keywords = keywords
		}
		print(String(jsonAnswer!)) // keep this for testing...
		return newSection
	}
	
	
	@IBOutlet weak var isbnLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorsLabel: UILabel!
	@IBOutlet weak var coverImage: UIImageView!
	
	@IBAction func addButton(sender: UIButton) {
		sections.append(newSection)
		//segue
	}
	@IBAction func dismissButton(sender: UIButton) {
		//Segue
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "backFromDismiss" {
			print("Going back from Dismiss")
		}
		else if segue.identifier == "backFromAdd"{
			print("Going back from Add")
		}
		else{
			print("Who send me here?")
		}
    }

}
