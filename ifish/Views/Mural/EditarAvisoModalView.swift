//
//  NovoAvisoModalView.swift
//  ifish
//
//  Created by Aluno 19 on 23/06/25.
//

import Foundation
import SwiftUI

struct EditarAvisoModalView: View {
    @Environment(\.dismiss) var fecharModalEditarAviso
    @State private var nomeAviso: String = ""
    @State private var descricaoAviso: String = ""
    @State private var dataAviso: Date = Date()
    @State private var notificacoesAviso: Bool = true

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Título", text: $nomeAviso)
                }

                Section {
                    DatePicker("Data", selection: $dataAviso, displayedComponents: [.date, .hourAndMinute])
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if descricaoAviso.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $descricaoAviso)
                            .frame(minHeight: 100)
                            .padding(4)
                    }
                }

                Section {
                    Toggle("Notificações", isOn: $notificacoesAviso)
                }
            }
            .navigationTitle("Editar Aviso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharModalEditarAviso()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        print("Título: \(nomeAviso)")
                        print("Data: \(dataAviso)")
                        print("Descrição: \(descricaoAviso)")
                        print("Notificações: \(notificacoesAviso)")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

