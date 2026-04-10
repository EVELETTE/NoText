//
//  notextApp.swift
//  notext
//
//  Created by Evelette Dylan on 09/04/2026.
//

import SwiftUI

@main
struct notextApp: App {
    @StateObject private var viewModel = TranscriptionViewModel()
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("À propos de NoText") {
                    openWindow(id: "about")
                }
            }
        }
        
        // Fenêtre À Propos
        Window("À propos de NoText", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        // Fenêtre de Préférences (Cmd + ,)
        Settings {
            SettingsView(viewModel: viewModel)
        }
        
        // Icône dans la barre des menus animée
        MenuBarExtra {
            Button("Ouvrir NoText") {
                NSApp.activate(ignoringOtherApps: true)
                for window in NSApp.windows where window.className == "SwiftUI.AppKitWindow" {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            .keyboardShortcut("o", modifiers: [.command])
            
            Divider()
            
            Button("Quitter NoText") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        } label: {
            if viewModel.isRecording {
                Image(systemName: viewModel.animationFrame % 2 == 0 ? "mic.circle" : "mic.circle.fill")
            } else if viewModel.isGeneratingAI {
                Image(systemName: viewModel.animationFrame % 2 == 0 ? "hourglass.bottomhalf.filled" : "hourglass.tophalf.filled")
            } else {
                Image(systemName: "waveform.circle")
            }
        }
    }
}
