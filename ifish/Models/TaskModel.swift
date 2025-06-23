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
}
