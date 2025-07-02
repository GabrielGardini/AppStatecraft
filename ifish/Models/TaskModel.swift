//
//  Task.swift
//  ifish
//
//  Created by Larissa on 10/06/25.
//

import Foundation
import CloudKit

func timestampToLembrete(prazo: Date, reminder: Date) -> Lembrete {
    let diff = prazo.timeIntervalSince(reminder)

    switch diff {
    case 0:
        return .naHora
    case 15 * 60:
        return .quinzeMinutos
    case 60 * 60:
        return .umaHora
    case 24 * 60 * 60:
        return .umDia
    default:
        return .nenhum
    }
}

func lembreteToTimestamp(prazo: Date, lembrete: Lembrete) -> Date {
    switch lembrete {
    case .nenhum:
        return prazo
    case .naHora:
        return prazo
    case .quinzeMinutos:
        return Calendar.current.date(byAdding: .minute, value: -15, to: prazo) ?? prazo
    case .umaHora:
        return Calendar.current.date(byAdding: .hour, value: -1, to: prazo) ?? prazo
    case .umDia:
        return Calendar.current.date(byAdding: .day, value: -1, to: prazo) ?? prazo
    }
}

enum Lembrete: String, CaseIterable, Identifiable {
    case nenhum = "Nenhum"
    case naHora = "Na mesma hora"
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
    @Published var userID: CKRecord.ID
    @Published var casaID: CKRecord.ID
    
    @Published var icone: String
    @Published var titulo: String
    @Published var descricao: String
    @Published var prazo: Date
    @Published var repeticao: Repeticao
    @Published var lembrete: Lembrete
    @Published var completo: Bool
    
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
    }
    
    static func vazia(casaID: CKRecord.ID? = nil, userID: CKRecord.ID? = nil) -> TaskModel {
        return TaskModel(
            id: CKRecord.ID(recordName: UUID().uuidString),
            userID: userID ?? CKRecord.ID(recordName: "undefined"),
            casaID: casaID ?? CKRecord.ID(recordName: "undefined"),
            icone: "",
            titulo: "",
            descricao: "",
            prazo: Date(),
            repeticao: .nunca,
            lembrete: .nenhum,
            completo: false
        )
    }
    
    func criarProximaTarefaRecorrente() -> TaskModel? {
        var novaData: Date?

        switch repeticao {
        case .diariamente:
            novaData = Calendar.current.date(byAdding: .day, value: 1, to: prazo)
        case .semanalmente:
            novaData = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: prazo)
        case .mensalmente:
            novaData = Calendar.current.date(byAdding: .month, value: 1, to: prazo)
        case .nunca:
            return nil
        }

        guard let novoPrazo = novaData else { return nil }

        let novaTask = TaskModel(
            id: CKRecord.ID(recordName: UUID().uuidString),
            userID: userID,
            casaID: casaID,
            icone: icone,
            titulo: titulo,
            descricao: descricao,
            prazo: novoPrazo,
            repeticao: repeticao,
            lembrete: lembrete,
            completo: false
        )

        return novaTask
    }

    convenience init?(record: CKRecord) {
        guard
            let userRef = record["UserID"] as? CKRecord.Reference,
            let casaRef = record["HouseID"] as? CKRecord.Reference,
            let icone = record["Icon"] as? String,
            let titulo = record["Title"] as? String,
            let descricao = record["Description"] as? String,
            let prazo = record["Deadline"] as? Date,
            let repeticaoStr = record["Frequency"] as? String,
            let repeticao = Repeticao(rawValue: repeticaoStr),
            let lembreteDate = record["Reminder"] as? Date,
            let completo = record["IsCompleted"] as? Bool
        else {
            print("❌ Erro ao converter CKRecord para TaskModel")
            return nil
        }

        let lembrete = timestampToLembrete(prazo: prazo, reminder: lembreteDate)

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
        record["Icon"] = icone as CKRecordValue
        record["Title"] = titulo as CKRecordValue
        record["Description"] = descricao as CKRecordValue
        record["Deadline"] = prazo as CKRecordValue
        record["Frequency"] = repeticao.rawValue as CKRecordValue
        // chama funcao para transformar Lembrete em data
        record["Reminder"] = lembreteToTimestamp(prazo: prazo, lembrete: lembrete) as CKRecordValue
        record["IsCompleted"] = completo as CKRecordValue
        return record
    }
    
    func atualizarCamposEm(_ record: CKRecord) {
        record["UserID"] = CKRecord.Reference(recordID: userID, action: .none)
        record["HouseID"] = CKRecord.Reference(recordID: casaID, action: .none)
        record["Icon"] = icone as CKRecordValue
        record["Title"] = titulo as CKRecordValue
        record["Description"] = descricao as CKRecordValue
        record["Deadline"] = prazo as CKRecordValue
        record["Frequency"] = repeticao.rawValue as CKRecordValue
        record["Reminder"] = lembreteToTimestamp(prazo: prazo, lembrete: lembrete) as CKRecordValue
        record["IsCompleted"] = completo as CKRecordValue
    }

}
