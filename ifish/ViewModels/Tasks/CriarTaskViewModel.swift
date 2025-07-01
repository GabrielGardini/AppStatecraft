//
//  CriarTaskViewModel.swift
//  ifish
//
//  Created by Larissa on 27/06/25.
//

import Foundation

class CriarTaskViewModel: ObservableObject {
    @Published var task: TaskModel
    
    init(task: TaskModel) {
        self.task = task
    }
}
