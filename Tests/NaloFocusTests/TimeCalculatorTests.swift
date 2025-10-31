//
//  TimeCalculatorTests.swift
//  NaloFocusTests
//
//  Unit tests for TimeCalculator
//

import XCTest
@testable import NaloFocus

final class TimeCalculatorTests: XCTestCase {
    var calculator: TimeCalculator!

    override func setUp() {
        super.setUp()
        calculator = TimeCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    func testGenerateTimeline() {
        // Given
        var session = SprintSession()
        session.tasks = [
            SprintTask(duration: 25 * 60), // 25 minutes
            SprintTask(duration: 15 * 60, hasBreak: true, breakDuration: 5 * 60) // 15 min + 5 min break
        ]

        // When
        let timeline = calculator.generateTimeline(from: session)

        // Then
        XCTAssertEqual(timeline.count, 3) // 2 tasks + 1 break
        XCTAssertEqual(timeline[0].type, .task)
        XCTAssertEqual(timeline[1].type, .task)
        XCTAssertEqual(timeline[2].type, .breakTime)
    }

    func testCalculateEndTime() {
        // Given
        let startTime = Date()
        let tasks = [
            SprintTask(duration: 25 * 60),
            SprintTask(duration: 25 * 60)
        ]

        // When
        let endTime = calculator.calculateEndTime(startTime: startTime, tasks: tasks)

        // Then
        let expectedDuration: TimeInterval = 50 * 60 // 50 minutes total
        XCTAssertEqual(endTime.timeIntervalSince(startTime), expectedDuration, accuracy: 1.0)
    }
}
