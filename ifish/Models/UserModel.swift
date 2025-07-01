//
//  User.swift
//  ifish
//
//  Created by Larissa on 10/06/25.
//

import CloudKit

class UserModel: ObservableObject, Identifiable, Hashable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: CKRecord.ID
    var name: String
    let houseID: CKRecord.ID
    let icloudToken: CKRecord.ID
    
    init(id: CKRecord.ID, name: String, houseID: CKRecord.ID, icloudToken: CKRecord.ID) {
        self.id = id
        self.name = name
        self.houseID = houseID
        self.icloudToken = icloudToken
    }
}
