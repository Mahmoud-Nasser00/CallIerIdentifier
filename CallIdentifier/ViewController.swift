//
//  ViewController.swift
//  CallIdentifier
//
//  Created by Mahmoud Nasser on 10/03/2021.
//

import UIKit
import CoreData
import CallKit
import CallerData

class ViewController: UIViewController {

    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var callerTV:UITableView!
    
    private var showBlocked:Bool {
        self.segmentControl.selectedSegmentIndex == 1
    }
    
    lazy private var callerData = CallerData()
    private var resultsController : NSFetchedResultsController<Caller>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callerTV.delegate = self
        callerTV.dataSource = self
        loadData()
    }

    private func loadData(){
        self.navigationItem.title = self.showBlocked ? "Blocked" : "ID"
        
        let fetchRequest : NSFetchRequest<Caller> = callerData.fetchRequest(blocked: showBlocked)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        self.resultsController.delegate = self
        do {
            try self.resultsController.performFetch()
            self.callerTV.reloadData()
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func segmentValueChanged(_ sender:UISegmentedControl){
        print(sender.selectedSegmentIndex)
        loadData()
    }
    
    @IBAction func unwindFromSave(_ sender: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AddEditViewController {
            dest.isBlocked = showBlocked
            dest.callerData = callerData
            if let cell = sender as? UITableViewCell {
                let indexPath = callerTV.indexPath(for: cell)!
                let caller = resultsController.fetchedObjects?[indexPath.row]
                dest.caller = caller
            }
        }
    }
    
    
}

extension ViewController:NSFetchedResultsControllerDelegate {
    
    // 1. Changes are coming from the NSFetchedResultsController`
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        callerTV.beginUpdates()
    }
    
    // 2. Process a change...
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let newIndexPath: IndexPath? = newIndexPath != nil ? IndexPath(row: newIndexPath!.row, section: 0) : nil
        let currentIndexPath: IndexPath? = indexPath != nil ? IndexPath(row: indexPath!.row, section: 0) : nil
        
        switch type {
        case .delete:
            callerTV.deleteRows(at: [currentIndexPath!], with: .fade)
        case .insert:
            callerTV.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            callerTV.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            callerTV.reloadRows(at: [currentIndexPath!], with: .automatic)
        @unknown default:
            fatalError()
        }
        
    }
    
    //3.  All changes have been delivered
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        callerTV.endUpdates()
    }
    
}

extension ViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if let caller = resultsController.fetchedObjects?[indexPath.row] {
                caller.isRemoved = true
                caller.updateDate = Date()
                callerData.saveContext()
            }
        default: break
        }
    }
    
}

extension ViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallerCell", for: indexPath)
        
        let caller = resultsController.fetchedObjects![indexPath.row]
        
//        cell.textLabel?.text = caller.isBlocked ? String(caller.number) : caller.name ?? ""
//        cell.detailTextLabel?.text = caller.isBlocked ? "" : String(caller.number)
        
        cell.textLabel?.text = String(caller.number)
        cell.detailTextLabel?.text = caller.name
        
        return cell
    }
    
}
