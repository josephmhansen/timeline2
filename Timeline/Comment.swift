//
//  Comment.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/6/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation
import CloudKit

struct Comment {
    static let kType = "Comment"
    static let kText = "text"
    static let kPost = "post"
    static let kTimestamp = "timestamp"
    static let kPostReference = "postReference"
    
    let text: String
    let timestamp: NSDate
    var post: Post?
    
    
    
    init(post: Post?, text: String, timestamp: NSDate = NSDate()) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    init?(record: CKRecord) {
        guard let timestamp = record[Comment.kTimestamp] as? NSDate,
            let text = record[Comment.kText] as? String
            else { return nil }
        self.init(post: nil, text: text, timestamp: timestamp)
        cloudKitRecordID = record.recordID
    }
    
    var cloudKitRecordID: CKRecordID?
    var recordType: String { return Comment.kType }
}

extension Comment: SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text.containsString(searchTerm)
    }
}

extension CKRecord {
    convenience init(_ comment: Comment) {
        let recordID = CKRecordID(recordName: NSUUID().UUIDString)
        self.init(recordType: Comment.kType, recordID: recordID)
        
        self[Comment.kTimestamp] = comment.timestamp
        guard let postRecordID = comment.post?.cloudKitRecordID else { return }
        let ref = CKReference(recordID: postRecordID, action: .DeleteSelf)
        self[Comment.kPostReference] = ref
        self[Comment.kText] = comment.text
    }
}