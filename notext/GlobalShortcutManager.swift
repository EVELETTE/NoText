import Foundation
import Cocoa
import ApplicationServices
import SwiftUI
import Combine

class GlobalShortcutManager: ObservableObject {
    @Published var isAccessibilityGranted: Bool = false
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    // Key codes
    private let optionKeyMask: NSEvent.ModifierFlags = .option
    private var isOptionPressed = false
    
    var onKeyDown: (() -> Void)?
    var onKeyUp: (() -> Void)?
    
    init() {
        checkAccessibilityPermissions()
        setupListeners()
    }
    
    deinit {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        isAccessibilityGranted = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        isAccessibilityGranted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !isAccessibilityGranted {
            // Open System Preferences -> Privacy -> Accessibility
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func setupListeners() {
        // Global monitor (when app is in background)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }
        
        // Local monitor (when app is in foreground)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }
    }
    
    private func handleFlagsChanged(_ event: NSEvent) {
        // La touche Option (gauche ou droite) est-elle enfoncée ?
        let isPressedNow = event.modifierFlags.contains(.option)
        
        if isPressedNow && !isOptionPressed {
            isOptionPressed = true
            DispatchQueue.main.async {
                self.onKeyDown?()
            }
        } else if !isPressedNow && isOptionPressed {
            isOptionPressed = false
            DispatchQueue.main.async {
                self.onKeyUp?()
            }
        }
    }
    
    func simulatePaste() {
        // Simulate Cmd + V sequence using CGEvent
        
        // Press Cmd
        let cmdDown = CGEvent(keyboardEventSource: nil, virtualKey: 55, keyDown: true)
        cmdDown?.flags = .maskCommand
        
        // Press V
        let vDown = CGEvent(keyboardEventSource: nil, virtualKey: 9, keyDown: true)
        vDown?.flags = .maskCommand
        
        // Release V
        let vUp = CGEvent(keyboardEventSource: nil, virtualKey: 9, keyDown: false)
        vUp?.flags = .maskCommand
        
        // Release Cmd
        let cmdUp = CGEvent(keyboardEventSource: nil, virtualKey: 55, keyDown: false)
        
        // Post events
        let loc = CGEventTapLocation.cghidEventTap
        cmdDown?.post(tap: loc)
        vDown?.post(tap: loc)
        vUp?.post(tap: loc)
        cmdUp?.post(tap: loc)
    }
}
