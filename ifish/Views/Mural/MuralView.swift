//
//  Mural.swift
//  ifish
//
//  Created by Aluno 15 on 16/06/25.
//

import Foundation
import SwiftUI
import CloudKit

struct MockMessage: Identifiable {
    let id = UUID()
    let descricao: String
    let houseID: CKRecord.Reference
    let timestamp: Date
    let titulo: String
    let userID: CKRecord.Reference
}
let mockMessages: [MockMessage] = [
    MockMessage(
        descricao: "Lembrete da reunião amanhã às 10h.",
        houseID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "Casa123"), action: .none),
        timestamp: Date(),
        titulo: "Reunião",
        userID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "UserA"), action: .none)
    ),
    MockMessage(
        descricao: "Precisamos comprar papel higiênico.snisnjjnjnjnjnjnjnjnjnjjhvjhvjkyhkyfkyhkyfkykfddgjhdygjhfykugfhdyfkgjfkuggjfkyugfhkygukfyugkfgjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjnjn",
        houseID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "Casa123"), action: .none),
        timestamp: Date().addingTimeInterval(-3600),
        titulo: "Compras",
        userID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "UserB"), action: .none)
    ),
    MockMessage(
        descricao: "Feliz aniversário, João!",
        houseID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "Casa123"), action: .none),
        timestamp: Date().addingTimeInterval(-86400),
        titulo: "Parabéns",
        userID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "UserC"), action: .none)
    )
]





struct MuralView: View {
    @State private var mostrarModalNovoAviso = false
    
    var body: some View{
        NavigationView{
            ZStack{
                LinearGradient(colors: [Color("LaranjaFundoMural"), Color("BackgroundColor")], startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.2))
                    .ignoresSafeArea()
                
                ScrollView {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height:150)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top)
                        Spacer().frame(height: 10)
                    
                    ForEach(mockMessages) { aviso in
                        AvisoView(nomeAviso: aviso.titulo, descricaoAviso: aviso.descricao, userID: aviso.userID)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            Spacer().frame(height: 10)
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
}



struct AvisoView: View{
    let nomeAviso: String
    let descricaoAviso: String
    let userID: CKRecord.Reference
    
    @State private var mostrarModalEditarAviso = false
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Aviso")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("LaranjaMural"))
                Text("•")
                    .font(.headline)

                Text(userID.recordID.recordName)
                    .font(.subheadline)

                Spacer()
                Button(action: {
                    mostrarModalEditarAviso = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
           }
            .padding(.bottom, 4)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .bottom
            )
            Spacer().frame(height: 4)

            Text(nomeAviso)
                .font(.headline)
            Spacer().frame(height: 4)
            Text(descricaoAviso)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        
        .sheet(isPresented: $mostrarModalEditarAviso) {
            EditarAvisoModalView()
        }
    }
}
