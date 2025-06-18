//
//  AppState.swift
//  ifish
//
//  Created by Larissa on 18/06/25.
//

import Foundation
import CloudKit

class AppState: ObservableObject {
    @Published var casaID: CKRecord.ID?
    @Published var userID: CKRecord.ID?
    @Published var usuario: UserModel?
}
