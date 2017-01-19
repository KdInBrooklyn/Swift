//
//  ViewController.swift
//  ClearStyle
//
//  Created by Audrey M Tam on 4/08/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
                            
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 50.0
        tableView.backgroundColor = UIColor.black
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        
        if toDoItems.count > 0 {
            return
        }
        toDoItems.append(ToDoItem(text: "feed the cat"))
        toDoItems.append(ToDoItem(text: "buy eggs"))
        toDoItems.append(ToDoItem(text: "watch WWDC videos"))
        toDoItems.append(ToDoItem(text: "rule the Web"))
        toDoItems.append(ToDoItem(text: "buy a new iPhone"))
        toDoItems.append(ToDoItem(text: "darn holes in socks"))
        toDoItems.append(ToDoItem(text: "write this tutorial"))
        toDoItems.append(ToDoItem(text: "master Swift"))
        toDoItems.append(ToDoItem(text: "learn to draw"))
        toDoItems.append(ToDoItem(text: "get more exercise"))
        toDoItems.append(ToDoItem(text: "catch up with Mom"))
        toDoItems.append(ToDoItem(text: "get a hair cut"))
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomCell
        
        if (cell == nil) {
            cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        
        cell?.delegate = self
        let item = toDoItems[indexPath.row]
        cell?.toDoItem = item
//        cell!.textLabel?.text = item.text
//        cell?.textLabel?.backgroundColor = UIColor.clear
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    // MARK: - private method
    func colorForIndex(_ index: Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
}

//MARK: - CustomCellDelegate
extension ViewController: CustomCellDelegate {
    //完成删除的逻辑操作
    func toDoItemDeleted(_ toDoItem: ToDoItem) {
        let index = toDoItems.index(of: toDoItem)
        
        if index == NSNotFound {
            return
        }
        
        toDoItems.remove(at: index!)
        
        
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index!, section: 0)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()
    }
}
