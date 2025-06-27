//
//  TasksViewModel.swift
//  ifish
//
//  Created by Lari on 16/06/25.
//

import Foundation
import CloudKit

class TasksViewModel: ObservableObject {
    @Published var tarefas: [TaskModel] = []
    
//    func buscarTarefas() -> tarefas {
//        
//    }
    
    init() {
        self.tarefas = []
    }
}
