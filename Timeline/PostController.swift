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
        let sortDescriptor = NSSortDescriptor(key: Post.kTimestamp, ascending: false)
        
        cloudKitManager.fetchRecordsWithType(Post.recordType, sortDescriptors: [sortDescriptor]) { (records, error) in
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
        cloudKitManager.saveRecord(CKRecord(post)) { (error) in
            if error != nil {
                print("Error saving post record to cloudkit \(error?.localizedDescription)")
            } else {
                self.posts.insert(post, atIndex: 0)
                print("Successfully saved post record to cloudkit")
            }
        }
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
}
    


