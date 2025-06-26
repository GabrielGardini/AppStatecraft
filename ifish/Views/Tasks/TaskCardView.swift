//
//  TaskCard.swift
//  ifish
//
//  Created by Larissa on 16/06/25.
//

import SwiftUI
import CloudKit

struct TaskCard: View {
    @ObservedObject var task: TaskModel
    
    var body: some View {
        HStack {
            
            // icone da tarefa
            IconeEstilo(icone: task.icone, selecionado: true)
            
            // titulo
            Text(task.titulo)
            Spacer()
            
            // nome do usuario associado
            Text(task.user?.name ?? "Desconhecido")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct TaskCard_Previews: PreviewProvider {
    static var previews: some View {
        // IDs mock
        let mockUserID = CKRecord.ID(recordName: "mock-user-id")
        let mockHouseID = CKRecord.ID(recordName: "mock-house-id")

        // usuário mock
        let mockUser = UserModel(id: mockUserID, name: "João da Silva", houseID: mockHouseID)

        // task mock associando o user
        let mockTask = TaskModel(
            id: CKRecord.ID(recordName: "mock-task-id"),
            userID: mockUserID,
            casaID: mockHouseID,
            icone: "leaf.fill",
            titulo: "Regar as plantas",
            descricao: "Lembrar de regar todas as plantas da varanda",
            prazo: Date(),
            repeticao: .semanalmente,
            lembrete: .quinzeMinutos,
            completo: false,
            user: mockUser
        )
        
        return TaskCard(task: mockTask)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
