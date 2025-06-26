//
//  IconeEstilo.swift
//  ifish
//
//  Created by Larissa on 25/06/25.
//

import SwiftUI

struct IconeEstilo: View {
    let icone: String
    var selecionado: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(selecionado ? Color.blue : Color.gray.opacity(0.9))
                .frame(width: 40, height: 40)
            
            Image(systemName: icone)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
        }
    }
}

struct IconeEstilo_Previews: PreviewProvider {
    static var previews: some View {
        IconeEstilo(icone: "trash.fill", selecionado: false)
    }
}
