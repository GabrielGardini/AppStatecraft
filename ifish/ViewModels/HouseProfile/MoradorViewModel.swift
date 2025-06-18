//
//  MoradorViewModel.swift
//  ifish
//
//  Created by Aluno 29 on 18/06/25.
//

import Foundation
import CloudKit

class MoradorViewModel: ObservableObject {
    @Published var morador: [UserModel] = []
    
    init(morador: [UserModel]) {
        self.morador = morador
    }
}
