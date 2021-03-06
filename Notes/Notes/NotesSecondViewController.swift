//
//  NotesSecondViewController.swift
//  Notes
//
//  Created by FelixXiao on 2017/1/13.
//  Copyright © 2017年 FelixXiao. All rights reserved.
//

import UIKit
var notesList: [NotesModel] = [NotesModel(title: "ANotes", content: "AContent"),
                               NotesModel(title: "BNotes", content: "BContend")]
var showList: [NotesModel] = []
var filterShowList: [NotesModel] = []

class NotesSecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating {

    var folderName = "init";
    var folderIndex = 0;
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var notesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.frame.size.height = 40

        notesTableView.tableHeaderView = searchController.searchBar
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterShowList.count
        }
        else {
            return showList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.notesTableView.dequeueReusableCell(withIdentifier: "noteCell")! as UITableViewCell
        let title = cell.viewWithTag(201) as! UILabel
        var temp: NotesModel
        if searchController.isActive && searchController.searchBar.text != "" {
            temp = filterShowList[indexPath.row]
        }
        else {
            temp = showList[indexPath.row]
        }
        
        title.text = temp.title
        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let notes = segue.destination as! NotesDetailViewController
            let indexPath = notesTableView.indexPathForSelectedRow
            if let index = indexPath {
                notes.titleString = showList[index.row].title
                notes.contentString = showList[index.row].content
                notes.notesIndex = index.row
            }
        }
        else if segue.identifier == "addNote" {
            let notes = segue.destination as! NotesDetailViewController
            notes.isAdd = 1
        }
    }
    
    @IBAction func close(_ segue: UIStoryboardSegue) {
        //print("closed!")
        notesTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        folderList[folderIndex].notes = showList
        
        let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/notes.dat"
        var array = NSMutableArray()
        var num = 0
        for item in folderList {
            array.insert(item.name, at: num)
            num = num + 1
            array.insert(item.notes.count.description, at: num)
            num = num + 1
            for var i in 0 ..< item.notes.count {
                array.insert(item.notes[i].title, at: num)
                num = num + 1
                array.insert(item.notes[i].content, at: num)
                num = num + 1
                i = i + 1
            }
        }
        NSKeyedArchiver.archiveRootObject(array, toFile: filePath)
        
        notesTableView.reloadData()
    }
    
    //edit mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        notesTableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.isEditing
    }
    
    //move cell
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let note = showList.remove(at: sourceIndexPath.row)
        showList.insert(note, at: destinationIndexPath.row)
    }
    
    //delete cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            showList.remove(at: indexPath.row)
            folderList[folderIndex].notes = showList
            
            let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/notes.dat"
            var array = NSMutableArray()
            var num = 0
            for item in folderList {
                array.insert(item.name, at: num)
                num = num + 1
                array.insert(item.notes.count.description, at: num)
                num = num + 1
                for var i in 0 ..< item.notes.count {
                    array.insert(item.notes[i].title, at: num)
                    num = num + 1
                    array.insert(item.notes[i].content, at: num)
                    num = num + 1
                    i = i + 1
                }
            }
            NSKeyedArchiver.archiveRootObject(array, toFile: filePath)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func updateSearchResults(for searchController: UISearchController) {
        
        filterContent(searchText: self.searchController.searchBar.text! )
    }
    
    func filterContent(searchText:String) {
        filterShowList = showList.filter { n in
            let name = n.title
            return (name.contains(searchText))
        }
        notesTableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
