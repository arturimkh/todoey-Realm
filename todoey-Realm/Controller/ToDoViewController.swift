//
//  ViewController.swift
//  todoey
//
//  Created by Artur Imanbaev on 21.03.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework
class ToDoViewController: UITableViewController {
    lazy var barButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        button.tintColor = .white
        return button
    }()
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category?{
        didSet{
            getData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(hexString: selectedCategory!.color)
        navigationController!.navigationBar.standardAppearance = navBarAppearance
        navigationController!.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = selectedCategory?.name
    }
    @objc
    private func addButtonPressed(){
        // если нажали на кнопку  закидывайм данные в массив и массив в файл
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default) { action in
            //saveItem
            do{
                try self.realm.write{
                    let item = Item()
                    item.title = textField.text ?? ""
                    item.dateCreated = Date().timeIntervalSince1970
                    self.selectedCategory?.items.append(item)
                }
            } catch{
                print("error saving category array \(error)")
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            textField.placeholder = "Type smth"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    func getData(){
        // получаем данные обычно в начале либо при поиске
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title",ascending: true)
        self.tableView.reloadData()
    }
    
    //MARK: dataSources Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // тут просто показываем данные с массива
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let item = todoItems?[indexPath.row]
        cell.textLabel?.text = item?.title ?? "dont have yet"
        cell.accessoryType = item!.done ? .checkmark: .none
        let selectedColor = UIColor(hexString: selectedCategory!.color)
        let color = selectedColor!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count) / 2)
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color!, returnFlat: true)
        return cell
    }
    
    //MARK: Delegates Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){ //отмечаем чекмарк и обновляем файл
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
                } catch{
                    print("error handling \(error)")
                }
            }
        tableView.reloadData()
    }
}
extension ToDoViewController{
    func setupUI(){
        setupTableView()
        setupNavigationItems()
        setupSearchBar()
    }
    func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
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
    }
}
extension ToDoViewController:UISearchBarDelegate,UISearchControllerDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        getData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            getData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

