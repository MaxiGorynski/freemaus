import Cocoa
import Foundation
import AppKit

class MouseController: NSObject {
    private var timer: Timer?
    private var shouldStop = false
    private var countdownTimer: Timer?
    private var timeUntilNextClick: TimeInterval = 0
    private var statusWindow: NSWindow?
    private var statusLabel: NSTextField?

    override init() {
        super.init()
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { _ in
            self.stopMouseMovement()
        }
        createStatusWindow()
    }

    func startMouseMovement() {
        scheduleNextMouseClick()
    }

    private func scheduleNextMouseClick() {
        timeUntilNextClick = TimeInterval.random(in: 20...120)
        updateStatusLabel()
        timer = Timer.scheduledTimer(timeInterval: timeUntilNextClick, target: self, selector: #selector(moveMouseAndClick), userInfo: nil, repeats: false)
    }

    @objc private func moveMouseAndClick() {
        guard !shouldStop else { return }
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        let randomX = CGFloat.random(in: 0...screenSize.width)
        let randomY = CGFloat.random(in: 0...screenSize.height)
        let randomPoint = CGPoint(x: randomX, y: randomY)

        moveMouse(to: randomPoint)
        clickMouse(at: randomPoint)
        scheduleNextMouseClick()
    }

    private func moveMouse(to point: CGPoint) {
        let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)
        event?.post(tap: .cghidEventTap)
    }

    private func clickMouse(at point: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }

    func stopMouseMovement() {
        shouldStop = true
        timer?.invalidate()
        countdownTimer?.invalidate()
        timer = nil
        countdownTimer = nil
        statusWindow?.close()
    }

    private func createStatusWindow() {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 100
        let windowFrame = NSRect(x: screenSize.width - windowWidth - 20, y: screenSize.height - windowHeight - 20, width: windowWidth, height: windowHeight)

        statusWindow = NSWindow(contentRect: windowFrame, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        statusWindow?.level = .floating
        statusWindow?.isReleasedWhenClosed = false

        statusLabel = NSTextField(labelWithString: "Freemaus is taking care of it. Hit any key to disable")
        statusLabel?.frame = NSRect(x: 20, y: 40, width: windowWidth - 40, height: 40)
        statusLabel?.alignment = .center
        statusLabel?.font = NSFont.systemFont(ofSize: 14)

        if let contentView = statusWindow?.contentView {
            contentView.addSubview(statusLabel!)
        }

        statusWindow?.makeKeyAndOrderFront(nil)
    }

    private func updateStatusLabel() {
        statusLabel?.stringValue = "Freemaus is taking care of it. Hit any key to disable\nTime Until Next Click: \(Int(timeUntilNextClick)) seconds"
    }
}

let mouseController = MouseController()
mouseController.startMouseMovement()

RunLoop.main.run()
//
//  app.swift
//  Freemaus
//
//  Created by Supriya Rai on 06/12/2024.
//

