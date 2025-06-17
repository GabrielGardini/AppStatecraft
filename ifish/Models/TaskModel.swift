//
//  Task.swift
//  ifish
//
//  Created by Larissa on 10/06/25.
//

import Foundation
import CloudKit

class TaskModel: ObservableObject, Identifiable {
    let id: CKRecord.ID
    let userID: CKRecord.ID
    let casaID: CKRecord.ID
    
    @Published var icone: String
    @Published var titulo: String
    @Published var descricao: String
    @Published var prazo: Date
    @Published var completo: Bool
    @Published var user: UserModel?
    
    init(id: CKRecord.ID, userID: CKRecord.ID, casaID: CKRecord.ID, icone: String,
        titulo: String, descricao: String, prazo: Date, completo: Bool = false,
         user: UserModel? = nil) {
        self.id = id
        self.userID = userID
        self.casaID = casaID
        self.icone = icone
        self.titulo = titulo
        self.descricao = descricao
        self.prazo = prazo
        self.completo = completo
        self.user = user
    }
}
