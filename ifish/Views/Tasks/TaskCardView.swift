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
    var iconeAlterado: String? = nil
    var corFundoIcone: Color? = nil
    var nomeUsuario: String? = nil
    
    var body: some View {
        HStack {
            // icone da tarefa
            IconeEstilo(icone: iconeAlterado ?? task.icone,
                        selecionado: true,
                        corFundoIcone: corFundoIcone ?? Color("TasksMainColor")
            )
            
            // titulo
            Text(task.titulo)
            Spacer()
            
            // nome do usuario associado
            Text(nomeUsuario ?? "Desconhecido")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct TaskCard_Previews: PreviewProvider {
    static var previews: some View {
        // IDs mock
        let mockUserID = CKRecord.ID(recordName: "mock-user-id")
        let mockHouseID = CKRecord.ID(recordName: "mock-house-id")

        let mockICloudToken1 = CKRecord.ID(recordName: "_mock-icloud-token-1")

        let mockUser = UserModel(
            id: mockUserID,
            name: "Joao da silva",
            houseID: mockHouseID,
            icloudToken: mockICloudToken1
        )
        
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
            completo: false
        )
        
        return TaskCard(task: mockTask, nomeUsuario: "teste")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
