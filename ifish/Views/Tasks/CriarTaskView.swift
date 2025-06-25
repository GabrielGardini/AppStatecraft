//
//  CriarTaskView.swift
//  ifish
//
//  Created by Larissa on 23/06/25.
//

import SwiftUI
import CloudKit

struct CriarTaskModalView: View {
    @Environment(\.dismiss) var fecharCriarTaskModalView
    @ObservedObject var houseViewModel = HouseProfileViewModel()
    @EnvironmentObject var appState: AppState

    @State private var tarefaCriada: TaskModel
    
    init() {
        let task = TaskModel(
            id: CKRecord.ID(recordName: UUID().uuidString),
            userID: AppState().userID ?? CKRecord.ID(recordName: "UserID"),
            casaID: AppState().casaID ?? CKRecord.ID(recordName: "HouseID"),
            icone: "square.and.pencil",
            titulo: "",
            descricao: "",
            prazo: Date(),
            repeticao: .nunca,
            lembrete: .nenhum,
            completo: false,
            user: AppState().usuario
        )
        _tarefaCriada = State(initialValue: task)
    }

    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Título", text: $tarefaCriada.titulo)
                    // retangulo para navegar pra outra tela (modelos pre prontos >)
                }
                
                Section {
                    DatePicker("Prazo", selection: $tarefaCriada.prazo, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    Picker("Repetição", selection: $tarefaCriada.repeticao) {
                        ForEach(Repeticao.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                    Picker("Lembrete", selection: $tarefaCriada.lembrete) {
                        ForEach(Lembrete.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                }
                
                Section {
                    Picker("Responsável", selection: $tarefaCriada.user) {
                        ForEach(houseViewModel.usuariosDaCasa) { usuario in
                            Text(usuario.name).tag(usuario.name)
                        }
                    }
                }
                
                Section {
                    Label("Icones", systemImage: "")
                        .labelStyle(.titleOnly)
                        .foregroundColor(.gray)
                    
                }
                Section {
                    ZStack(alignment: .topLeading) {
                        if tarefaCriada.descricao.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $tarefaCriada.descricao)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Nova tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharCriarTaskModalView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                    }
                }
            }
            .task {
                await houseViewModel.buscarUsuariosDaMinhaCasa()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct CriarTaskView_Previews: PreviewProvider {
    static var previews: some View {
        // IDs mock
        let mockUserID = CKRecord.ID(recordName: "mock-user-id")
        let mockHouseID = CKRecord.ID(recordName: "mock-house-id")

        // usuário mock
        let mockUser = UserModel(id: mockUserID, name: "Maria Lucia", houseID: mockHouseID)

        let mockTask = TaskModel(
            id: CKRecord.ID(recordName: "mock-task2-id"),
            userID: mockUserID,
            casaID: mockHouseID,
            icone: "leaf.fill",
            titulo: "Regar as plantas",
            descricao: "",
            prazo: Date(),
            repeticao: .semanalmente,
            lembrete: .quinzeMinutos,
            completo: false,
            user: mockUser
        )
        
        CriarTaskModalView()
    }
}
