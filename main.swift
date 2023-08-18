import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var mouseMonitor: Any?
    var keyboardMonitor: Any?

    // debounce timers
    var lastMouseTimestamp: TimeInterval = 0
    var lastKeyboardTimestamp: TimeInterval = 0
    var typingStartedTimestamp: TimeInterval = 0
    var mouseMoveStartedTimestamp: TimeInterval = 0
    var debounceTimer: Timer?
    let debounceInterval: TimeInterval = 0.5

    // total values to log
    var totalKeyPresses: Int = 0
    var totalMouseMoves: Int = 0
    var totalMouseTime: TimeInterval = 0
    var totalKeyboardTime: TimeInterval = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Tracking mouse and keyboard activity (time in seconds)")

        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            let now = event.timestamp
            if self.mouseMoveStartedTimestamp == 0 {
                self.mouseMoveStartedTimestamp = now
            }
            
            // Invalidate previous timer if it exists
            self.debounceTimer?.invalidate()
            
            // Schedule a new timer
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: self.debounceInterval, repeats: false) { _ in
                let deltaTime = now - self.mouseMoveStartedTimestamp
                self.totalMouseTime += deltaTime
                self.mouseMoveStartedTimestamp = 0
                self.totalMouseMoves += 1
                print("\t🐭 [add] added \(deltaTime) to totalMouseTime")
                print("\t🐭 [move] mouseMoved: \(event.locationInWindow)")
            }
            
            self.lastMouseTimestamp = now
        }

        keyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let now = event.timestamp
            if self.typingStartedTimestamp == 0 {
                self.typingStartedTimestamp = now
            }

            // Invalidate previous timer if it exists
            self.debounceTimer?.invalidate()
            
            // Schedule a new timer
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: self.debounceInterval, repeats: false) { _ in
                let deltaTime = now - self.typingStartedTimestamp
                self.totalKeyboardTime += deltaTime
                self.typingStartedTimestamp = 0
                print("\t🎹 [add] added \(deltaTime) to totalKeyboardTime")
            }
            print("\t🎹 [press] keyDown: \(event.keyCode)")
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
            "mouseTime": self.totalMouseTime,
            "keyboardTime": self.totalKeyboardTime,
            "totalKeyPresses": self.totalKeyPresses,
            "totalMouseMoves": self.totalMouseMoves
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: activityData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        // print json to stdout
        print(jsonString)
        
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let fileURL = homeDirectory.appendingPathComponent("activity.json")
        try! jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

let appDelegate = AppDelegate()
let application = NSApplication.shared
application.delegate = appDelegate
application.run()
