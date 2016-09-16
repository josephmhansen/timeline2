//
//  PostController.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/6/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//
import UIKit
import Foundation
import CloudKit

class PostController {
    static let sharedController = PostController()
    private let cloudKitManager = CloudKitManager()
    
    init() {
//        self.cloudKitManager = CloudKitManager()
        
    
    }
    
    var posts: [Post] = [] {
        didSet {
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName("postsWereUpdated", object: nil)
                    print(self.posts.count)
                }
        }
    }
    
    var captions: [String] = []
    
    func searchForPostWithCaption(caption: String) -> [Post] {
        return posts.filter({$0.caption.lowercaseString.containsString(caption.lowercaseString)})
    }
    
    func fetchPosts(completion: (NSError?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        cloudKitManager.fetchRecordsWithType(Post.recordType, sortDescriptors: [sortDescriptor], predicate: NSPredicate(value: true), recordFetchedBlock: { (record) in
        
            }) { (records, error) in
                if error != nil {
                    print("Error fetching messages \(error?.localizedDescription)")
                    completion(error)
                } else {
                    guard let records = records else { return }
                    let posts = records.flatMap({Post(record: $0)})
                    self.posts = posts
                }
        }
    }
            
    
    
    
    func createPost(post: Post, completion: ((NSError?) -> Void) = {_ in}) {
        let record = CKRecord(post)
        cloudKitManager.saveRecord(record) { (error) in
            if error != nil {
                print("Error saving post record to cloudkit \(error?.localizedDescription)")
            } else {
                self.posts.insert(post, atIndex: 0)
                print("Successfully saved post record to cloudkit")
            }
        }
        post.cloudKitRecordID = record.recordID
    }
    
    func addCommentToPost(text: String, post: Post, completion: ((Comment) -> Void)? = nil) -> Comment {
        let comment = Comment(post: post, text: text)
        post.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (error) in
            if error != nil {
                print("Error saving comment to post in cloudKit")
            } else {
                print("Success, created comment succesfully")
            }
        }
        return comment
    }
    
    func fetchCommentsForPost(post: Post, completion: (() -> Void)? = nil) {
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        guard let recordID = post.cloudKitRecordID else { return }
        let reference = CKReference(recordID: recordID, action: .DeleteSelf)
        let predicate = NSPredicate(format: "postReference == %@", reference)
        
        cloudKitManager.fetchRecordsWithType(Comment.kType, sortDescriptors: [sortDescriptor], predicate: predicate, recordFetchedBlock: { (record) in
            
            }) { (records, error) in
                guard let records = records else { return }
                let comments = records.flatMap({Comment(record: $0)})
                post.comments = comments
                completion?()
        }
        
        
    }
    
    func subscribeToCreationOfPosts(completion: ((NSError?) -> Void)? = nil) {
        cloudKitManager.subscribeToCreationOfRecordsWithType(Post.recordType) { (error) in
            if let error = error {
                print("Error saving subscription: \(error.localizedDescription)")
            } else {
                print("Successfully subscribed to push notifications for new messages")
            }
            completion?(error)
        }
    }
    
    func enableSubscriptionToPostComments(post: Post, alertBody: String?, completion: ((success: Bool, error: NSError?) -> Void)?) {
        guard let recordID = post.cloudKitRecordID else { fatalError("Error creating CloudKit Reference for Subscription.") }
        let predicate = NSPredicate(format: "postReference == %@", argumentArray: [recordID])
        
        cloudKitManager.subscribe(Comment.kType, predicate: predicate, subscriptionID: recordID.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: [Comment.kText, Comment.kPostReference], options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success: success, error: error)
                print(error)
            }
        }
    }
    
    func disableSubscriptionToPostComments(post: Post, completion: ((success: Bool, error: NSError?) -> Void)?) {
        guard let subscriptionID = post.cloudKitRecordID?.recordName else {
            completion?(success: true, error: nil)
            return
        }
        
        cloudKitManager.unsubscribe(subscriptionID) { (subscriptionID, error) in
            if let completion = completion {
                let success = subscriptionID != nil && error == nil
                completion(success: success, error: error)
            }
        }
    }
    
    func togglePostCommentSubscription(post: Post, completion: ((success: Bool, isSubscribed: Bool, error: NSError?) -> Void)?) {
        guard let subscriptionID = post.cloudKitRecordID?.recordName else {
            completion?(success: false, isSubscribed: false, error: nil)
            return
        }
        
        cloudKitManager.fetchSubscription(subscriptionID) { (subscription, error) in
            if subscription != nil {
                self.disableSubscriptionToPostComments(post, completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: false, error: error)
                    }
                })
                
            } else {
                self.enableSubscriptionToPostComments(post, alertBody: "New comment on a Subscribed Post", completion: { (success, error) in
                    if let completion = completion {
                        completion(success: true, isSubscribed: true, error: error)
                    }
                })
            }
        }
    }

}