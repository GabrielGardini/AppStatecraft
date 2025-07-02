//
//  EditarTaskView.swift
//  ifish
//
//  Created by Larissa on 18/06/25.
//

import SwiftUI
import CloudKit

struct EditarTaskModalView: View {
    @Environment(\.dismiss) var fecharEditarTaskModalView
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @EnvironmentObject var viewModel: TasksViewModel

    @ObservedObject var task: TaskModel
    @State private var erroTituloVazio = false
    @State private var erroIconeVazio = false
    @State private var mostrarAlertaApagar = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Título", text: $task.titulo)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(erroTituloVazio ? Color.red : Color.clear, lineWidth: 1)
                        )
                }

                Section {
                    DatePicker("Prazo", selection: $task.prazo, displayedComponents: [.date, .hourAndMinute])
                }

                Section {
                    Picker("Repetição", selection: $task.repeticao) {
                        ForEach(Repeticao.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                    Picker("Lembrete", selection: $task.lembrete) {
                        ForEach(Lembrete.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                }

                Section {
                    Picker("Responsável", selection: $task.userID) {
                        ForEach(houseViewModel.usuariosDaCasa) { usuario in
                            Text(usuario.name)
                                .tag(usuario.icloudToken)
                        }
                    }
                }

                Section {
                    Label("Ícones", systemImage: "")
                        .labelStyle(.titleOnly)
                        .foregroundColor(erroIconeVazio ? .red : .gray)

                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 35))]) {
                            ForEach(IconesDisponiveis.todos, id: \.self) { icone in
                                Button(action: {
                                    task.icone = icone
                                }) {
                                    IconeEstilo(icone: icone, selecionado: task.icone == icone)
                                }
                                .padding(4)
                            }
                        }
                    }
                    .frame(height: 130)
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if task.descricao.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $task.descricao)
                            .frame(minHeight: 100)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        mostrarAlertaApagar = true
                    } label: {
                        Text("Apagar tarefa")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

            }
            .navigationTitle("Editar tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharEditarTaskModalView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task {
                            let tituloValido = !task.titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            let iconeValido = !task.icone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                            erroTituloVazio = !tituloValido
                            erroIconeVazio = !iconeValido

                            if !tituloValido || !iconeValido {
                                return
                            }

                            await viewModel.editarTarefa(task)
                            fecharEditarTaskModalView()
                        }
                    }
                    .alert("Tem certeza que deseja apagar esta tarefa?", isPresented: $mostrarAlertaApagar) {
                        Button("Apagar", role: .destructive) {
                            Task {
                                await viewModel.apagarTarefa(task)
                                fecharEditarTaskModalView()
                            }
                        }
                        Button("Cancelar", role: .cancel) { }
                    }
                }
    
            }
            .onAppear {
                if houseViewModel.usuariosDaCasa.isEmpty {
                    Task {
                        await houseViewModel.buscarUsuariosDaMinhaCasa()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
