//
//  ViewController.swift
//  Todoey
//
//  Created by 黄苏渝 on 2019/1/25.
//  Copyright © 2019 suyu. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categorySelected : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.separatorStyle = .none
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = categorySelected?.name
        
        guard let colorHex = categorySelected?.color else{fatalError("color not found")}
        
        updateNavBar(withHexCode: colorHex)
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else{fatalError("Navigation Controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError("NOT UICOLOR EXITST")}
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard let originalColor = UIColor(hexString: "ff6666") else {fatalError("UICOLOR 0abab5 NOT FOUND")}
        
        updateNavBar(withHexCode: "ff6666")
    }
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: categorySelected!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error selecting item \(error)")
            }
        }
        

        
       tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
   
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in
            
            
            if let currentCategory = self.categorySelected {
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.done = false
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item \(error)")
                }
                
            }
            
            self.tableView.reloadData()
            
//            let newItem = Item(context: self.context)
//            newItem.title = textField.text!
//            newItem.done = false
//            newItem.parentCategory = self.categorySelected
//            
//            self.itemArray.append(newItem)
            

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {

        todoItems = categorySelected?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categorySelected!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//
//        do {
//           itemArray =  try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//
//        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemsForDeletion = todoItems?[indexPath.row] {
            do {
                
                try self.realm.write {
                    
                    self.realm.delete(itemsForDeletion)
                    
                }
                
            } catch {
                print("Error deleting items, \(error)")
            }
        }
    }
    

    
}

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("adasd")
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {

            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }



        } else {

        }
    }
}
