import CloudKit

class MessageModel {
    let id: CKRecord.ID
    var content: String
    var houseID: CKRecord.Reference
    var timestamp: Date
    var title: String
    var userID: CKRecord.Reference

    init(id: CKRecord.ID, content: String, houseID: CKRecord.Reference, timestamp: Date, title: String, userID: CKRecord.Reference) {
        self.id = id
        self.content = content
        self.houseID = houseID
        self.timestamp = timestamp
        self.title = title
        self.userID = userID
    }

    convenience init(record: CKRecord) {
        let id = record.recordID
        let content = record["Content"] as? String ?? ""
        let houseID = record["HouseID"] as? CKRecord.Reference ?? CKRecord.Reference(recordID: CKRecord.ID(recordName: "ERRO"), action: .none)
        let timestamp = record["Timestamp"] as? Date ?? Date()
        let title = record["Title"] as? String ?? ""
        let userID = record["UserID"] as? CKRecord.Reference ?? CKRecord.Reference(recordID: CKRecord.ID(recordName: "ERRO"), action: .none)

        self.init(id: id, content: content, houseID: houseID, timestamp: timestamp, title: title, userID: userID)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Message", recordID: id)
        record["Content"] = content as CKRecordValue
        record["HouseID"] = houseID
        record["Timestamp"] = timestamp as CKRecordValue
        record["Title"] = title as CKRecordValue
        record["UserID"] = userID
        return record
    }
}
