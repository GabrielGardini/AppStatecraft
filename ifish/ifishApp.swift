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

    @StateObject private var appState = AppState()
    @StateObject private var houseViewModel = HouseProfileViewModel()

    
    var body: some Scene {
        WindowGroup {
            AppStartView()
                .background(Color("BackgroundColor").ignoresSafeArea())
                .environmentObject(appState)
                .environmentObject(houseViewModel)
        }
    }
}
