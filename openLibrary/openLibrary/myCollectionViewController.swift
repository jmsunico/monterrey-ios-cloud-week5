//
//  myCollectionViewController.swift
//  openLibrary3
//
//  Created by José-María Súnico on 20160710.
//  Copyright © 2016 José-María Súnico. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class myCollectionViewController: UICollectionViewController {
/*
	struct Section{
		var name: String
		var images: [UIImage]
		init(name: String, images: [UIImage]){
			self.name = name
			self.images = images
		}
	}
	var sections = [Section]()
*/
	struct Section{
		var isbn: String
		var title: String
		var authors: String
		var pubdate: String
		var url: String
		var keywords: String
		var errors: String
		var cover: UIImage
		init(isbn: String){
			self.isbn = isbn
			self.title = ""
			self.authors = ""
			self.pubdate = ""
			self.url = ""
			self.keywords = ""
			self.errors = ""
			self.cover = UIImage(named: "pending")!
		}
	}
	var sections = [Section]()
	
	
	@IBAction func searchTextField(sender: UITextField) {
		let newISBN : String? = sender.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		if (newISBN != nil) && (newISBN! != ""){
			let newSection = searchISBN(newISBN!)
			if (newSection.errors == ""){
				sections.append(newSection)
				self.collectionView!.reloadData()
			}
			else{
				//ANALYSE ERRORS!!!
				let alert = UIAlertController(title: "ERRORS!", message: "newSection.errors", preferredStyle: .Alert)
				let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alert.addAction(accion)
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}
/*
	@IBAction func ISBN1(sender: AnyObject) {
	self.isbnText.text = "978-84-376-0494-7"
	}
	@IBAction func ISBN2(sender: AnyObject) {
	self.isbnText.text = "978-84-973-6467-6"
	}
	
	func googleCustomSearch (term: String) -> [UIImage]{
		var images = [UIImage]()
		let urlPrefix = "https://www.googleapis.com/customsearch/v1?key=AIzaSyBy5Cq8SQ0dscc8XYD3SNgo7PNNuTujgMg&cx=007652608310439950328:jhyvpayzsq0&searchType=image&q="
		let url = NSURL(string: urlPrefix + term)
		let data = NSData(contentsOfURL: url!)
		do{
			let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
			let itemsArray = jsonDict["items"] as! NSArray
			for item in itemsArray{
				let linkString = (item as! NSDictionary)["link"] as! String
				let linkURL = NSURL(string: linkString)
				let linkData = NSData(contentsOfURL: linkURL!)
				if linkData != nil{
					if let image = UIImage(data: linkData!){
						images.append(image)
					}
				}
			}
		} catch _{
			print("Something nasty happened...")
		}
		return images
	}
*/
	
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
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sections.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //return self.sections[section].images.count
		return 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! cellView
		cell.cellImage.image = sections[indexPath.section].cover
		
        // Configure the cell
    
        return cell
    }
	
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		let cell2 = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Cell2", forIndexPath: indexPath) as! sectionHeader
		
		cell2.sectionHeaderLabel.text = sections[indexPath.section].title
		return cell2
	}
	
}