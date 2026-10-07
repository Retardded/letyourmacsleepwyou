import Cocoa
import AVFoundation

let d = UserDefaults.standard
var minutes = d.object(forKey: "min") as? Int ?? 10
var useMic = d.object(forKey: "mic") as? Bool ?? true
var lastLoud = Date()
let loud: Float = 0.01  // RMS ≈ -40 dB; calibrate if room noise triggers it

let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
item.button?.image = NSImage(systemSymbolName: "moon.zzz", accessibilityDescription: "LetYourMacSleep")  // template: подстраивается под тему меню-бара
let engine = AVAudioEngine()

func startMic() {
    guard useMic else { engine.stop(); engine.inputNode.removeTap(onBus: 0); return }
    AVCaptureDevice.requestAccess(for: .audio) { ok in
        guard ok else { return }
        let n = engine.inputNode
        n.removeTap(onBus: 0)
        n.installTap(onBus: 0, bufferSize: 4096, format: nil) { buf, _ in
            guard let c = buf.floatChannelData?[0] else { return }
            var s: Float = 0
            for i in 0..<Int(buf.frameLength) { s += c[i] * c[i] }
            if (s / Float(max(buf.frameLength, 1))).squareRoot() > loud { lastLoud = Date() }
        }
        try? engine.start()
    }
}

// pids holding sleep-preventing assertions (skips our own process)
func blockers() -> [(pid: Int32, name: String)] {
    let p = Process(); let pipe = Pipe()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/pmset"); p.arguments = ["-g", "assertions"]
    p.standardOutput = pipe; try? p.run()
    let out = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    var r: [(Int32, String)] = []
    let re = try! NSRegularExpression(pattern: #"pid (\d+)\(([^)]+)\):.*(PreventUserIdleSystemSleep|PreventSystemSleep)"#)
    for l in out.split(separator: "\n") {
        let s = String(l); let ns = s as NSString
        if let m = re.firstMatch(in: s, range: NSRange(location: 0, length: ns.length)) {
            let pid = Int32(ns.substring(with: m.range(at: 1)))!
            if pid != getpid() && !r.contains(where: { $0.0 == pid }) { r.append((pid, ns.substring(with: m.range(at: 2)))) }
        }
    }
    return r
}

func tick() {
    let anyEvent = CGEventType(rawValue: ~0)!
    var idle = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyEvent)
    if useMic { idle = min(idle, Date().timeIntervalSince(lastLoud)) }
    guard idle >= Double(minutes * 60) else { return }
    let b = blockers()
    guard !b.isEmpty else { return }  // nothing blocks sleep; macOS sleeps on its own
    for (pid, _) in b {
        if let app = NSRunningApplication(processIdentifier: pid), app.activationPolicy == .regular { app.terminate() }
        else { kill(pid, SIGTERM) }  // caffeinate & co
    }
    lastLoud = Date()
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/bin/pmset"); p.arguments = ["sleepnow"]; try? p.run()
    }
}

class Menu: NSObject {
    @objc func pick(_ s: NSMenuItem) { minutes = s.tag; d.set(minutes, forKey: "min"); build() }
    @objc func mic(_ s: NSMenuItem) { useMic.toggle(); d.set(useMic, forKey: "mic"); startMic(); build() }
    func build() {
        let m = NSMenu()
        m.addItem(withTitle: "Sleep after idle:", action: nil, keyEquivalent: "")
        for t in [1, 5, 10, 15, 30, 60] {
            let i = NSMenuItem(title: "\(t) min", action: #selector(pick), keyEquivalent: ""); i.target = self; i.tag = t
            i.state = t == minutes ? .on : .off; m.addItem(i)
        }
        m.addItem(.separator())
        let mi = NSMenuItem(title: "Listen to microphone", action: #selector(mic), keyEquivalent: ""); mi.target = self
        mi.state = useMic ? .on : .off; m.addItem(mi)
        m.addItem(.separator())
        m.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q")
        item.menu = m
    }
}

let menu = Menu(); menu.build(); startMic()
Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in tick() }
NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.run()
