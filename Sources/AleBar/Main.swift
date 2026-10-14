import Foundation
import AppKit

@main
enum Main {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate.shared
        app.delegate = delegate
        app.run()
    }
}
