//
//  User.swift
//  ifish
//
//  Created by Larissa on 10/06/25.
//

import CloudKit

class UserModel {
    let id: CKRecord.ID
    var name: String
    let houseID: CKRecord.ID
    
    init(id: CKRecord.ID, name: String, houseID: CKRecord.ID) {
        self.id = id
        self.name = name
        self.houseID = houseID
    }
}
