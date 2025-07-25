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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @EnvironmentObject var viewModel: TasksViewModel

    @ObservedObject var task: TaskModel

    @State private var mostrarConfirmacaoCancelar = false
    @State private var mostrarModalSelecionarTarefa = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Título", text: $task.titulo)

                    Button(action: {
                        mostrarModalSelecionarTarefa = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Selecionar tarefa pronta")
                        }
                    }
                    .sheet(isPresented: $mostrarModalSelecionarTarefa) {
                        SelecionarTarefaProntaView(task: task)
                    }

                }
                
                Section {
                    DatePicker("Prazo", selection: $task.prazo, in: Date()...,displayedComponents: [.date, .hourAndMinute])
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
                            Text(
                                appState.userID == usuario.icloudToken ? "Eu" :
                                                                        usuario.name
                            )
                                .tag(usuario.icloudToken)
                        }
                    }
                }
                
                Section {
                    Label("Ícones", systemImage: "")
                        .labelStyle(.titleOnly)
                        .foregroundColor(.gray)
                    
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 35))]) {
                            ForEach(IconesDisponiveis.todos, id: \.self) { icone in
                                Button(action: {
                                    task.icone = icone
                                    print("\(task.icone)")
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
            }
            .navigationTitle("Nova tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        if (task.titulo == "") {
                            fecharCriarTaskModalView()
                        } else {
                            mostrarConfirmacaoCancelar = true
                    }
                    }
                    .confirmationDialog("Tem certeza de que deseja descartar as alterações?", isPresented: $mostrarConfirmacaoCancelar, titleVisibility: .visible){
                        Button("Ignorar alterações", role: .destructive){
                            Task {
                                fecharCriarTaskModalView()
                            }
                        }
                        Button("Continuar Editando", role: .cancel){}
                        .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        Task {
                            if let houseModel = houseViewModel.houseModel {
                                await viewModel.criarTarefa(task: task, houseModel: houseModel)
                            } else {
                                print("❌ Nenhuma casa vinculada.")
                            }
                            fecharCriarTaskModalView()
                        }
                    }
                    .disabled(task.titulo == "")
                }
            }
            .task {
                await houseViewModel.buscarUsuariosDaMinhaCasa()
            }
        }
        .navigationViewStyle(.stack)
    }
}


struct SelecionarTarefaProntaView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var task: TaskModel
    @State private var searchText = ""

    var tarefasFiltradas: [TarefaPronta] {
        if searchText.isEmpty {
            return TarefasProntasMock.lista
        } else {
            return TarefasProntasMock.lista.filter {
                $0.titulo.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(tarefasFiltradas) { tarefa in
                        Button {
                            task.titulo = tarefa.titulo
                            task.icone = tarefa.icone
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                IconeEstilo(icone: tarefa.icone, selecionado: true)
                                
                                Text(tarefa.titulo)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                        }
                        .listRowInsets(EdgeInsets()) // remove padding lateral padrão da List
                        .listRowBackground(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                    }
                }
                .listStyle(.plain)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Selecionar Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
    }
}
