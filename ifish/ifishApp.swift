//
//  ifishApp.swift
//  ifish
//
//  Created by Aluno 15 on 04/06/25.
//

import SwiftUI

@main
struct ifishApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
