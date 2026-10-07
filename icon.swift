// Generates icon.icns: swift icon.swift
import Cocoa
let S: CGFloat = 1024
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
let r = NSRect(x: 100, y: 100, width: S - 200, height: S - 200)
let bg = NSBezierPath(roundedRect: r, xRadius: 185, yRadius: 185)
NSGradient(colors: [NSColor(red: 0.36, green: 0.30, blue: 0.85, alpha: 1), NSColor(red: 0.07, green: 0.09, blue: 0.30, alpha: 1)])!.draw(in: bg, angle: -90)
let cfg = NSImage.SymbolConfiguration(pointSize: 420, weight: .regular)
let sym = NSImage(systemSymbolName: "moon.zzz.fill", accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
let t = NSImage(size: sym.size); t.lockFocus()
sym.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: 1)
NSColor.white.set(); NSRect(origin: .zero, size: sym.size).fill(using: .sourceAtop); t.unlockFocus()
t.draw(at: NSPoint(x: (S - t.size.width) / 2, y: (S - t.size.height) / 2), from: .zero, operation: .sourceOver, fraction: 1)
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "icon_1024.png"))
