//
//  PerfilView.swift
//  ifish
//
//  Created by Aluno 29 on 17/06/25.
//

import SwiftUI

struct PerfilView: View {
    var body: some View {
                ZStack {
                    Color(red: 249/255, green: 249/255, blue: 249/255) // #F9F9F9
                        .ignoresSafeArea()
                
            VStack(spacing: 20) {
                // Ícone e título
                VStack {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 75, height: 60)
                        .foregroundColor(.green)
                    Text("Minha casa")
                      .font(Font.custom("SF Pro", size: 24))
                      .multilineTextAlignment(.center)
                      .foregroundColor(.black)
                      .frame(width: 190, height: 39, alignment: .top)

                                    Spacer() // empurra o resto pra baixo
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 327, height: 247)
                      .background(Color("#F6F6F6"))
                      .cornerRadius(6)
                                }
                }}}
    // Nome da casa + mascote
    
}
