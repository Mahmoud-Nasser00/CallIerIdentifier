//
//  CallerData.swift
//  CallerData
//
//  Created by Mahmoud Nasser on 10/03/2021.
//

import Foundation
import CoreData


public final class CallerData {
    
    public init() {
        
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let momdName = "CallIdentifier"
        let groupName = "group.com.callIdentifier"
        let fileName = "demo.sqlite"
        
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension: "momd")
        else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        guard let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)
        else {
            fatalError("Error creating base URL for \(groupName)")
        }
        
        let storeURL = baseURL.appendingPathComponent(fileName)
        
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        
        let description = NSPersistentStoreDescription()
        
        description.url = storeURL
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    public var context :NSManagedObjectContext {
        self.persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support

    public func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func fetchRequest(blocked:Bool,includeRemoved:Bool = false,since date:Date? = nil) -> NSFetchRequest<Caller>{
        
        let fetchRequest:NSFetchRequest<Caller> = Caller.fetchRequest()
        var predicates = [NSPredicate]()
        
        let blockedPredicate = NSPredicate(format: "isBlocked == %@",NSNumber(value: blocked))
        predicates.append(blockedPredicate)
        
        if !includeRemoved {
            let removedPredicate = NSPredicate(format: "isRemoved == %@", NSNumber(value: false))
            predicates.append(removedPredicate)
        }
        
        if let dateFrom = date {
            let datePredicate = NSPredicate(format: "updateDate > %@", dateFrom as NSDate)
            predicates.append(datePredicate)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        return fetchRequest
    }
    
}
