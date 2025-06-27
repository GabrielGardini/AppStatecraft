//
//  Task.swift
//  ifish
//
//  Created by Larissa on 10/06/25.
//

import Foundation
import CloudKit

enum Lembrete: String, CaseIterable, Identifiable {
    case nenhum = "Nenhum"
    case quinzeMinutos = "15 minutos antes"
    case umaHora = "1 Hora antes"
    case umDia = "1 dia antes"
    var id: String { rawValue }
}

enum Repeticao: String, CaseIterable, Identifiable {
    case nunca, diariamente, semanalmente, mensalmente
    var id: String { rawValue }
}


class TaskModel: ObservableObject, Identifiable {
    let id: CKRecord.ID
    let userID: CKRecord.ID
    let casaID: CKRecord.ID
    
    @Published var icone: String
    @Published var titulo: String
    @Published var descricao: String
    @Published var prazo: Date
    @Published var repeticao: Repeticao
    @Published var lembrete: Lembrete
    @Published var completo: Bool
    @Published var user: UserModel?
    
    init(id: CKRecord.ID, userID: CKRecord.ID, casaID: CKRecord.ID, icone: String,
         titulo: String, descricao: String, prazo: Date, repeticao: Repeticao, lembrete: Lembrete, completo: Bool = false,
         user: UserModel? = nil) {
        self.id = id
        self.userID = userID
        self.casaID = casaID
        self.icone = icone
        self.titulo = titulo
        self.descricao = descricao
        self.prazo = prazo
        self.repeticao = repeticao
        self.lembrete = lembrete
        self.completo = completo
        self.user = user
    }
    
    convenience init?(record: CKRecord) {
        guard
            let userRef = record["UserID"] as? CKRecord.Reference,
            let casaRef = record["HouseID"] as? CKRecord.Reference,
            let icone = record["Icone"] as? String,
            let titulo = record["Titulo"] as? String,
            let descricao = record["Descricao"] as? String,
            let prazo = record["Prazo"] as? Date,
            let repeticaoStr = record["Repeticao"] as? String,
            let repeticao = Repeticao(rawValue: repeticaoStr),
            let lembreteStr = record["Lembrete"] as? String,
            let lembrete = Lembrete(rawValue: lembreteStr),
            let completo = record["Completo"] as? Bool
        else {
            print("❌ Erro ao converter CKRecord para TaskModel")
            return nil
        }

        self.init(
            id: record.recordID,
            userID: userRef.recordID,
            casaID: casaRef.recordID,
            icone: icone,
            titulo: titulo,
            descricao: descricao,
            prazo: prazo,
            repeticao: repeticao,
            lembrete: lembrete,
            completo: completo
        )
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Task", recordID: id)
        record["UserID"] = CKRecord.Reference(recordID: userID, action: .none)
        record["HouseID"] = CKRecord.Reference(recordID: casaID, action: .none)
        record["Icone"] = icone as CKRecordValue
        record["Titulo"] = titulo as CKRecordValue
        record["Descricao"] = descricao as CKRecordValue
        record["Prazo"] = prazo as CKRecordValue
        record["Repeticao"] = repeticao.rawValue as CKRecordValue
        record["Lembrete"] = lembrete.rawValue as CKRecordValue
        record["Completo"] = completo as CKRecordValue
        return record
    }
}
