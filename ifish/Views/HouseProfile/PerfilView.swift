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
                
            HStack(spacing: 20) {
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
                                }
                HStack{
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#E1E1E1"))
                        .frame(width: 327, height: 106)
                    Text(casaID)
                        .font(.custom("SF Pro", size: 24))
                        .foregroundColor(.black)

                }
                
                
                }}}
    // Nome da casa + mascote
    
}
