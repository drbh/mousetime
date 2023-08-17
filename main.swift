import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var mouseMonitor: Any?
    var keyboardMonitor: Any?
    var lastMouseTimestamp: TimeInterval = 0
    var lastKeyboardTimestamp: TimeInterval = 0
    var totalKeyPresses: Int = 0
    var totalMouseTime: TimeInterval = 0
    var totalKeyboardTime: TimeInterval = 0
    var typingStartedTimestamp: TimeInterval = 0
    let pauseInterval: TimeInterval = 0.1

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Tracking mouse and keyboard activity (time in seconds)")

        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            if self.lastMouseTimestamp != 0 {
                let deltaTime = event.timestamp - self.lastMouseTimestamp
                self.totalMouseTime += deltaTime
            }
            // print("mouseMoved: \(event.locationInWindow)")
            self.lastMouseTimestamp = event.timestamp
        }
        
        keyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let now = event.timestamp
            if self.typingStartedTimestamp == 0 {
                self.typingStartedTimestamp = now
            }
            // print("keyDown: \(event.keyCode)")
            if self.lastKeyboardTimestamp != 0 && now - self.lastKeyboardTimestamp > self.pauseInterval {
                self.totalKeyboardTime += self.lastKeyboardTimestamp - self.typingStartedTimestamp
                self.typingStartedTimestamp = now
            }
            self.totalKeyPresses += 1
            self.lastKeyboardTimestamp = now
        }

        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.dumpActivity()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        if let monitor = keyboardMonitor {
            NSEvent.removeMonitor(monitor)
        }

        self.dumpActivity()
    }

    func dumpActivity() {
        let activityData: [String: Any] = [
            "mouseTime": totalMouseTime,
            "keyboardTime": totalKeyboardTime,
            "totalKeyPresses": totalKeyPresses
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: activityData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let fileURL = homeDirectory.appendingPathComponent("activity.json")
        try! jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

let appDelegate = AppDelegate()
let application = NSApplication.shared
application.delegate = appDelegate
application.run()
