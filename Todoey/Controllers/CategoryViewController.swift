//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 黄苏渝 on 2019/2/2.
//  Copyright © 2019 suyu. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categoryArray: Results<Category>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
        
        tableView.separatorStyle = .none
        
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
//        cell.delegate = self
        
        
        if let category = categoryArray?[indexPath.row]{
            
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            
        }
        
       
        
        return cell
    }
    
    // MARK: - TableView delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.categorySelected = categoryArray?[indexPath.row]
        }
        
    }

    func loadCategory() {
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath){
        
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do {
                
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
                
            } catch {
                print("error deleting category \(error)")
            }
        }
    }
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving Category \(error)")
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "add new category"
            
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
}

