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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @EnvironmentObject var viewModel: TasksViewModel
    
    @State private var mostrarConfirmacaoCancelar = false
       
    @ObservedObject var task: TaskModel
    @StateObject private var taskEditada: TaskModel

    init(task: TaskModel, onApagar: (() -> Void)? = nil) {
        self.task = task
        self._taskEditada = StateObject(wrappedValue: TaskModel(
            id: task.id,
            userID: task.userID,
            casaID: task.casaID,
            icone: task.icone,
            titulo: task.titulo,
            descricao: task.descricao,
            prazo: task.prazo,
            repeticao: task.repeticao,
            lembrete: task.lembrete,
            completo: task.completo
        ))
        self.onApagar = onApagar
    }

    var onApagar: (() -> Void)? = nil

    @State private var erroTituloVazio = false
    @State private var erroIconeVazio = false
    @State private var mostrarAlertaApagar = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Título", text: $taskEditada.titulo)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(erroTituloVazio ? Color.red : Color.clear, lineWidth: 1)
                        )
                }

                Section {
                    DatePicker("Prazo", selection: $taskEditada.prazo, displayedComponents: [.date, .hourAndMinute])
                }

                Section {
                    Picker("Repetição", selection: $taskEditada.repeticao) {
                        ForEach(Repeticao.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                    Picker("Lembrete", selection: $taskEditada.lembrete) {
                        ForEach(Lembrete.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                }

                Section {
                    Picker("Responsável", selection: $taskEditada.userID) {
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
                        .foregroundColor(erroIconeVazio ? .red : .gray)

                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 35))]) {
                            ForEach(IconesDisponiveis.todos, id: \.self) { icone in
                                Button(action: {
                                    taskEditada.icone = icone
                                }) {
                                    IconeEstilo(icone: icone, selecionado: taskEditada.icone == icone)
                                }
                                .padding(4)
                            }
                        }
                    }
                    .frame(height: 130)
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if taskEditada.descricao.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $taskEditada.descricao)
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
                    .confirmationDialog("Tem certeza que deseja apagar?", isPresented: $mostrarAlertaApagar, titleVisibility: .visible) {
                        Button("Apagar tarefa", role: .destructive) {
                            Task {
                                await viewModel.apagarTarefa(task)
                                fecharEditarTaskModalView()
                                onApagar?()  // avisa para a view de detalhe fechar
                            }
                        }
                        Button("Cancelar", role: .cancel) { }
                        .foregroundColor(.accentColor)
                    }
                }

            }
            .navigationTitle("Editar tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        if (task.userID == taskEditada.userID &&
                            task.icone == taskEditada.icone &&
                            task.titulo == taskEditada.titulo &&
                            task.descricao == taskEditada.descricao &&
                            task.prazo == taskEditada.prazo &&
                            task.repeticao == taskEditada.repeticao &&
                            task.lembrete == taskEditada.lembrete &&
                            task.completo == taskEditada.completo) {
                            fecharEditarTaskModalView()     // se nao houve modificaçao, so cancela
                        } else {
                            mostrarConfirmacaoCancelar = true   // se houve modificaçao, pede confirmaçao
                        }
                    }
                    .confirmationDialog("Tem certeza de que deseja descartar as alterações?", isPresented: $mostrarConfirmacaoCancelar, titleVisibility: .visible){
                        Button("Ignorar alterações", role: .destructive){
                            Task {
                                fecharEditarTaskModalView()
                            }
                        }
                        Button("Continuar Editando", role: .cancel){}
                        .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task {
                            let tituloValido = !taskEditada.titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            let iconeValido = !taskEditada.icone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                            erroTituloVazio = !tituloValido
                            erroIconeVazio = !iconeValido

                            if !tituloValido || !iconeValido {
                                return
                            }
                            
                            task.userID = taskEditada.userID
                            task.icone = taskEditada.icone
                            task.titulo = taskEditada.titulo
                            task.descricao = taskEditada.descricao
                            task.prazo = taskEditada.prazo
                            task.repeticao = taskEditada.repeticao
                            task.lembrete = taskEditada.lembrete
                            task.completo = taskEditada.completo
                            
                            await viewModel.editarTarefa(task)
                            fecharEditarTaskModalView()
                        }
                    }.disabled(
                        // estara desativado se todos os campos forem iguais
                        // repeticao desnecessaria - necessario refatorar
                        task.userID == taskEditada.userID &&
                        task.icone == taskEditada.icone &&
                        task.titulo == taskEditada.titulo &&
                        task.descricao == taskEditada.descricao &&
                        task.prazo == taskEditada.prazo &&
                        task.repeticao == taskEditada.repeticao &&
                        task.lembrete == taskEditada.lembrete &&
                        task.completo == taskEditada.completo
                    )
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

func tarefasIguais(task: TaskModel, taskEditada: TaskModel) -> Bool {
    return task.userID == taskEditada.userID &&
        task.icone == taskEditada.icone &&
        task.titulo == taskEditada.titulo &&
        task.descricao == taskEditada.descricao &&
        task.prazo == taskEditada.prazo &&
        task.repeticao == taskEditada.repeticao &&
        task.lembrete == taskEditada.lembrete &&
        task.completo == taskEditada.completo
}
