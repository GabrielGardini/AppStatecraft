import CloudKit

class FinanceModel {
    let id: CKRecord.ID
    var amount: Double
    var deadline: Date
    var houseID: CKRecord.Reference
    var paidBy: [String]
    var title: String

    init(id: CKRecord.ID, amount: Double, deadline: Date, houseID: CKRecord.Reference, paidBy: [String], title: String) {
        self.id = id
        self.amount = amount
        self.deadline = deadline
        self.houseID = houseID
        self.paidBy = paidBy
        self.title = title
    }

    convenience init(record: CKRecord) {
        let id = record.recordID
        let amount = record["Amount"] as? Double ?? 0.0
        let deadline = record["Deadline"] as? Date ?? Date()
        let houseID = record["HouseId"] as? CKRecord.Reference ?? CKRecord.Reference(recordID: CKRecord.ID(recordName: "ERRO"), action: .none)
        let paidBy = record["PaidBy"] as? [String] ?? []
        let title = record["Title"] as? String ?? ""
        
        self.init(id: id, amount: amount, deadline: deadline, houseID: houseID, paidBy: paidBy, title: title)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Expanse", recordID: id)
        record["Amount"] = amount as CKRecordValue
        record["Deadline"] = deadline as CKRecordValue
        record["HouseId"] = houseID
        record["PaidBy"] = paidBy as CKRecordValue
        record["Title"] = title as CKRecordValue
        return record
    }
}
