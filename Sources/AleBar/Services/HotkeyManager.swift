import Foundation
import AppKit

public final class HotkeyManager: @unchecked Sendable {
    public static let shared = HotkeyManager()
    
    public var onToggleBar: (() -> Void)?
    public var onOpenCommandBar: (() -> Void)?
    public var onOpenSettings: (() -> Void)?
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    private init() {}
    
    public func start() {
        stop()
        
        // Monitor key events
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Consume event
            }
            return event
        }
    }
    
    public func stop() {
        if let g = globalMonitor {
            NSEvent.removeMonitor(g)
            globalMonitor = nil
        }
        if let l = localMonitor {
            NSEvent.removeMonitor(l)
            localMonitor = nil
        }
    }
    
    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let keyCode = event.keyCode
        
        // ⌘ + ⌥ + B -> Toggle AleBar (B = 11)
        if flags == [.command, .option] && keyCode == 11 {
            DispatchQueue.main.async { [weak self] in
                self?.onToggleBar?()
            }
            return true
        }
        
        // ⌘ + ⌥ + Space -> Open Command Bar (Space = 49)
        if flags == [.command, .option] && keyCode == 49 {
            DispatchQueue.main.async { [weak self] in
                self?.onOpenCommandBar?()
            }
            return true
        }
        
        // ⌘ + ⌥ + , -> Open Settings (Comma = 43)
        if flags == [.command, .option] && keyCode == 43 {
            DispatchQueue.main.async { [weak self] in
                self?.onOpenSettings?()
            }
            return true
        }
        
        return false
    }
}
