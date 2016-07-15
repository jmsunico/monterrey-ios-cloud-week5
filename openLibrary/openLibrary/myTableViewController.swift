//
//  ViewController.swift
//  openLibrary3
//
//  Created by José-María Súnico on 20160710.
//  Copyright © 2016 José-María Súnico. All rights reserved.
//
/*
Instrucciones
=============
Desarrollar una aplicación en lenguaje SWIFT usando Xcode que realice una petición a https://openlibrary.org/ y que muestre el resultado en una tabla jerárquica a dos niveles:
	1. En el primer nivel se encontrará una vista tabla, mostrando los títulos de libros ya buscados. 
	2. En el segundo nivel se mostrará el detalle del libro que se seleccione en el primer nivel.
La idea es que los libros que se vayan buscando se vayan integrando en la estructura que representará la fuente de datos de la vista tabla. Puedes seleccionar, al momento de crear tu proyecto la plantilla Maestro-Detalle.
IMPORTANTE. AL momento de crear tu proyecto, no olvides seleccionar el uso de Core Data ya que se usará en ese módulo y así se facilitan las cosas

Review criteria
---------------
1 Al iniciar la aplicación, una vista tabla deberá ser mostrada
2. Deberá contener un UIBarButtonItem, en específico el Add (signo +) en la barra de navegación que permita hacer una búsqueda y añadir el libro a la tabla
3. Al presionar el botón de añadir (punto anterior), se deberá mostrar una vista que permita ingresar el ISBN de un libro y mostrar, en caso de éxito de la búsqueda:
		a. El título del libro
		b. Los autores del libro
		c. La portada (en caso de que se encuentre)
4. Al regresar a la vista tabla, el título del libro buscado deberá aparecer en la tabla
5. Si seleccionamos un renglón de la tabla que contenga un título de libro, deberá mostrar sus detalles
*/


import UIKit
import CoreData

public struct Section{
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
		self.errors = "Empty object"
		self.cover = UIImage(named: "pending")!
	}
}

public var myBooks = [NSManagedObject]()

class myTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	func data2image (imageData : NSData) -> UIImage {
		return UIImage(data: imageData)!
	}
	
	@IBAction func addBookButton(sender: UIBarButtonItem) {
		performSegueWithIdentifier("SearchISBN", sender: UIBarButtonItem.self)
	}
	
	@IBOutlet weak var myTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		title = "Book list"
		myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "BookCell")
		// Delegates
		myTableView.dataSource = self
		myTableView.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// 1. Prepare context
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext
		
		// 2. Recover data from database
		let fetchRequest = NSFetchRequest(entityName: "Book")
	
		// 3. Load data in the managed object
		do {
			let results =
				try managedContext.executeFetchRequest(fetchRequest)
			myBooks = results as! [NSManagedObject]
		}
		catch let error as NSError {
			print("Could not fetch \(error), \(error.userInfo)")
		}
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return myBooks.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = myTableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath)
		let thisBook = myBooks[indexPath.row]
		cell.textLabel!.text =  thisBook.valueForKey("title") as? String
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
		print("Selected row: ", indexPath.row)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		performSegueWithIdentifier("ViewDetails", sender: indexPath)
	}
	
	
	// Preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

		// Get the new view controller using segue.destinationViewController.
		if segue.identifier == "SearchISBN" {
			print("Am I a button?")
		}
		else if segue.identifier == "ViewDetails"{
			let index = sender!.row
			let viewDetails = segue.destinationViewController as! DetailsViewController
			viewDetails.index = index
		}
	}
}

