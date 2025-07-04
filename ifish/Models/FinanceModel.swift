import CloudKit

class FinanceModel: Identifiable {
    let id: CKRecord.ID
    var amount: Double
    var deadline: Date
    var houseID: CKRecord.Reference
    var paidBy: [String]
    var title: String
    var notification: Bool
    var shouldRepeat: Bool

    init(id: CKRecord.ID, amount: Double, deadline: Date, houseID: CKRecord.Reference, paidBy: [String], title: String, notification: Bool, shouldRepeat: Bool) {
        self.id = id
        self.amount = amount
        self.deadline = deadline
        self.houseID = houseID
        self.paidBy = paidBy
        self.title = title
        self.notification = notification
        self.shouldRepeat = shouldRepeat
    }

    convenience init(record: CKRecord) {
        let id = record.recordID
        let amount = record["Amount"] as? Double ?? 0.0
        let deadline = record["DeadLine"] as? Date ?? Date()
        let houseID = record["HouseId"] as? CKRecord.Reference ?? CKRecord.Reference(recordID: CKRecord.ID(recordName: "ERRO"), action: .none)
        let paidBy = record["PaidBy"] as? [String] ?? []
        let title = record["Title"] as? String ?? ""
        let notification = record["Notification"] as? Bool ?? true
        let shouldRepeat = record["Repeat"] as? Bool ?? true
        
        self.init(id: id, amount: amount, deadline: deadline, houseID: houseID, paidBy: paidBy, title: title, notification: notification, shouldRepeat: shouldRepeat)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Expanse", recordID: id)
        record["Amount"] = amount as CKRecordValue
        record["DeadLine"] = deadline as CKRecordValue
        record["HouseId"] = houseID
        record["PaidBy"] = paidBy as CKRecordValue
        record["Title"] = title as CKRecordValue
        record["Notification"] = notification as CKRecordValue
        record["Repeat"] = shouldRepeat as CKRecordValue
        return record
    }
}
