//
//  CategoryViewController.swift
//  todoey
//
//  Created by Artur Imanbaev on 24.03.2023.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework
class CategoryViewController: UITableViewController, UISearchBarDelegate {
    lazy var barButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        button.tintColor = .white
        return button
    }()
    var categoryArray: Results<Category>?

    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getCategories()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.navigationBar.sizeToFit()
        }
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        navigationController!.navigationBar.standardAppearance = navBarAppearance
        navigationController!.navigationBar.scrollEdgeAppearance = navBarAppearance
    }

    func saveCategories(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        } catch{
            print("error saving category array \(error)")
        }
        self.tableView.reloadData()
    }
    func getCategories(){
        categoryArray = realm.objects(Category.self)
        self.tableView.reloadData()
    }

    @objc
    private func addButtonPressed(){
        // если нажали на кнопку  закидывайм данные в массив и массив в файл
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default) { action in
            let category = Category()
            category.name = textField.text ?? ""
            category.color = UIColor.randomFlat().hexValue()
            self.saveCategories(category: category)
        }
        alert.addTextField { alertTextField in
            textField.placeholder = "Type smth"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCellId", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "no categories added yet"
        cell.backgroundColor = UIColor(hexString: categoryArray![indexPath.row].color)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = ToDoViewController()
        if let indexPath = tableView.indexPathForSelectedRow{
            destVC.selectedCategory = categoryArray?[indexPath.row]
        }
        navigationController?.pushViewController(destVC, animated: true)
    }

}
//MARK: setupUI
extension CategoryViewController {
    func setupUI(){
        setupTableView()
        setupNavigationItems()
        setupSearchBar()
    }
    func setupTableView(){
        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "categoryCellId")
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        
    }
    func setupNavigationItems() {
        navigationItem.title = "toDoye"
        navigationItem.rightBarButtonItem = barButton
    }
    func setupSearchBar(){
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        //tableView.tableHeaderView = search.searchBar это штука не работает!!
    }
}
//MARK: Swipe table view cell delegate
extension CategoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            do{
                try self.realm.write{
                    self.realm.delete((self.categoryArray?[indexPath.row])!)
                    }
                } catch{
                    print("error handling \(error)")
                }
            }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
