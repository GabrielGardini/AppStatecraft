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
    
    init(tarefas: [TaskModel]) {
        self.tarefas = tarefas
    }
}

