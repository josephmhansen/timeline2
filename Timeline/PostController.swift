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
    
    var posts: [Post] = []
    var captions: [String] = []
    
    func searchForPostWithCaption(caption: String) -> [Post] {
        return posts.filter({$0.caption.lowercaseString.containsString(caption.lowercaseString)})
    }
    
    
    func createPost(post: Post, completion: ((NSError?) -> Void) = {_ in}) {
        cloudKitManager.saveRecord(CKRecord(post)) { (error) in
            if error != nil {
                print("Error saving message record to cloudkit \(error?.localizedDescription)")
            } else {
                self.posts.insert(post, atIndex: 0)
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
}
    


