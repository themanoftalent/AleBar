import SwiftUI
import AppKit

public struct AboutSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Brand Header
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.12, green: 0.08, blue: 0.20),
                                        Color(red: 0.25, green: 0.15, blue: 0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.amberAccent.opacity(0.4), lineWidth: 2)
                            )
                            .shadow(color: Color.amberAccent.opacity(0.25), radius: 12, y: 6)
                        
                        Text("🍺")
                            .font(.system(size: 40))
                    }
                    .padding(.top, 10)
                    
                    VStack(spacing: 4) {
                        Text("AleBar")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        
                        Text("Version 1.0.0 (macOS Edition)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("The modern, native menu bar organizer for macOS.\nOwn your menu bar with in-bar collapse, notch-aware floating shelf, instant search, and smart event triggers.")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .padding(.horizontal, 40)
                }
                
                // GitHub and Links Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "https://github.com/themanoftalent/AleBar") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                            Text("GitHub Repository")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        if let url = URL(string: "https://github.com/themanoftalent/AleBar/releases") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Releases & Updates")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // System Diagnostics Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "macmini.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("System Environment & Diagnostics")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        
                        Button(action: copyDiagnostics) {
                            HStack(spacing: 4) {
                                Image(systemName: appState.aboutCopiedDiagnostics ? "checkmark" : "doc.on.doc")
                                Text(appState.aboutCopiedDiagnostics ? "Copied" : "Copy Info")
                            }
                            .font(.system(size: 11))
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    VStack(spacing: 6) {
                        DiagnosticRow(label: "Operating System", value: ProcessInfo.processInfo.operatingSystemVersionString)
                        DiagnosticRow(label: "Managed Items", value: "\(appState.items.count) items (\(appState.items.filter { $0.section == .shown }.count) shown, \(appState.items.filter { $0.section == .hidden }.count) hidden)")
                        DiagnosticRow(label: "Current Mode", value: appState.hidingMode.rawValue)
                        DiagnosticRow(label: "Active Theme", value: appState.theme.preset.rawValue)
                        DiagnosticRow(label: "Icon Style", value: appState.statusIconStyle.rawValue)
                        DiagnosticRow(label: "Architecture", value: getArchitecture())
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.03))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("Designed and built natively in Swift & AppKit for macOS Sonoma & Sequoia.")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 12)
            }
            .padding(10)
        }
    }
    
    private func getArchitecture() -> String {
        #if arch(arm64)
        return "Apple Silicon (arm64)"
        #elseif arch(x86_64)
        return "Intel (x86_64)"
        #else
        return "Universal"
        #endif
    }
    
    private func copyDiagnostics() {
        let text = """
        AleBar v1.0.0
        macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)
        Architecture: \(getArchitecture())
        Managed Items: \(appState.items.count)
        Hiding Mode: \(appState.hidingMode.rawValue)
        Theme Preset: \(appState.theme.preset.rawValue)
        Status Icon: \(appState.statusIconStyle.rawValue)
        """
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        
        appState.aboutCopiedDiagnostics = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            appState.aboutCopiedDiagnostics = false
        }
    }
}

// MARK: - Diagnostic Row
private struct DiagnosticRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
    }
}
