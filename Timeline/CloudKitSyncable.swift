//
//  CloudKitSyncable.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/14/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    init?(record: CKRecord)
    
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
}

extension CloudKitSyncable {
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    
    var cloudKitReference: CKReference? {
        guard let recordID = cloudKitRecordID else { return nil }
        return CKReference(recordID: recordID, action: .None)
    }
}
