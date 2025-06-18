//
//  Casa.swift
//  ifish
//
//  Created by Gabriel on 18/06/25.
//

import CloudKit

class HouseModel {
    let id: CKRecord.ID
    var nome: String
    var inviteCode: String

    init(id: CKRecord.ID, nome: String, inviteCode: String) {
        self.id = id
        self.nome = nome
        self.inviteCode = inviteCode
    }

    convenience init(record: CKRecord) {
        let id = record.recordID
        let nome = record["Nome"] as? String ?? ""
        let inviteCode = record["InviteCode"] as? String ?? ""
        self.init(id: id, nome: nome, inviteCode: inviteCode)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Casa", recordID: id)
        record["Nome"] = nome as CKRecordValue
        record["InviteCode"] = inviteCode as CKRecordValue
        return record
    }
}
