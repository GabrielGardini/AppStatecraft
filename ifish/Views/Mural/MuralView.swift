//
//  Mural.swift
//  ifish
//
//  Created by Aluno 15 on 16/06/25.
//

import Foundation
import SwiftUI

struct MuralView: View {
    @State private var mostrarModalNovoAviso = false
    
    var body: some View{
        NavigationView {

            ScrollView {
                ForEach(1..<10) { i in
                    Rectangle()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("Mural")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarModalNovoAviso = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            
            .sheet(isPresented: $mostrarModalNovoAviso) {
                NovoAvisoModalView()
            }
            
        }
    }
}


struct NovoAvisoModalView: View {
    @Environment(\.dismiss) var fecharModalNovoAviso
    @State private var nomeAviso: String = ""
    @State private var descricao: String = ""
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
                        if descricao.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $descricao)
                            .frame(minHeight: 100)
                            .padding(4)
                    }
                }

                Section {
                    Toggle("Notificações", isOn: $notificacoesAviso)
                }
            }
            .navigationTitle("Novo Aviso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharModalNovoAviso()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        print("Título: \(nomeAviso)")
                        print("Data: \(dataAviso)")
                        print("Descrição: \(descricao)")
                        print("Notificações: \(notificacoesAviso)")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}


/*struct AvisoView: View{
    $Binding var nomeAviso: String
    $Binding var descricaoAviso: String
    
    
    var body: some View {
        
    }
}*/

struct MuralView_Previews: PreviewProvider {
    static var previews: some View {
        MuralView()
        NovoAvisoModalView()
    }
}
