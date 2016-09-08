//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/6/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation

import CloudKit
import UIKit

class CloudKitManager {
    
    
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    
    func saveRecord(record: CKRecord, completion: ((NSError?) -> Void) = { _ in }) {
        
        publicDatabase.saveRecord(record) { (_, error) in
            completion(error)
        }
    }
    
    func fetchRecordsWithType(type: String, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((record: CKRecord) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let predicate = predicate
        let query = CKQuery(recordType: type, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { (fetchedRecord) -> Void in
            
            fetchedRecords.append(fetchedRecord)
            
            if let recordFetchedBlock = recordFetchedBlock {
                recordFetchedBlock(record: fetchedRecord)
            }
        }
        
        queryOperation.queryCompletionBlock = { (queryCursor, error) -> Void in
            
            if let queryCursor = queryCursor {
                // there are more results, go fetch them
                
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                continuedQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                
                self.publicDatabase.addOperation(continuedQueryOperation)
            } else {
                if let completion = completion {
                    completion(records: fetchedRecords, error: error)
                }
            }
        }
        
        self.publicDatabase.addOperation(queryOperation)
    }
    
    
    
    func subscribeToCreationOfRecordsWithType(type: String, completion: ((NSError?) -> Void)? = nil) {
        
        let subscription = CKSubscription(recordType: type, predicate: NSPredicate(value: true), options: .FiresOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "New Post on the board"
        notificationInfo.soundName = UILocalNotificationDefaultSoundName
        
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.saveSubscription(subscription) { (subscription, error) in
            if let error = error {
                print("Error saving subscription: \(error.localizedDescription)")
            }
            completion?(error)
        }
        
    }
    
    // MARK: - Delete
    
    func deleteRecordWithID(recordID: CKRecordID, completion: ((recordID: CKRecordID?, error: NSError?) -> Void)?) {
        
        publicDatabase.deleteRecordWithID(recordID) { (recordID, error) in
            
            if let completion = completion {
                completion(recordID: recordID, error: error)
            }
        }
    }
    
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((records: [CKRecord]?, recordIDs: [CKRecordID]?, error: NSError?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.savePolicy = .IfServerRecordUnchanged
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            
            if let completion = completion {
                completion(records: records, recordIDs: recordIDs, error: error)
            }
        }
    }
    
    // MARK: - CloudKit Permissions
    
    func checkCloudKitAvailability() {
        
        CKContainer.defaultContainer().accountStatusWithCompletionHandler() {
            (accountStatus:CKAccountStatus, error:NSError?) -> Void in
            
            switch accountStatus {
            case .Available:
                print("CloudKit available. Initializing full sync.")
                return
            default:
                self.handleCloudKitUnavailable(accountStatus, error: error)
            }
        }
    }
    
    func handleCloudKitUnavailable(accountStatus: CKAccountStatus, error:NSError?) {
        
        var errorText = "Synchronization is disabled\n"
        if let error = error {
            print("handleCloudKitUnavailable ERROR: \(error)")
            print("An error occured: \(error.localizedDescription)")
            errorText += error.localizedDescription
        }
        
        switch accountStatus {
        case .Restricted:
            errorText += "iCloud is not available due to restrictions"
        case .NoAccount:
            errorText += "There is no CloudKit account setup.\nYou can setup iCloud in the Settings app."
        default:
            break
        }
        
        displayCloudKitNotAvailableError(errorText)
    }
    
    func displayCloudKitNotAvailableError(errorText: String) {
        
        dispatch_async(dispatch_get_main_queue(),{
            
            let alertController = UIAlertController(title: "iCloud Synchronization Error", message: errorText, preferredStyle: .Alert)
            
            let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil);
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
}


    
    