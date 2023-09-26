// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import Client

import XCTest

class TabCellTests: XCTestCase {
    private func testState1() -> TabCellState {
        return TabCellState(isSelected: false,
                            isPrivate: false,
                            isFxHomeTab: false,
                            tabTitle: "Firefox Browser",
                            url: URL(string: "https://www.mozilla.org/en-US/firefox/")!,
                            screenshot: nil,
                            hasHomeScreenshot: false,
                            margin: 0.0)
    }

    override func setUp() {
        super.setUp()
    }

    func testTabCellDeinit() {
        let subject = TabCell(frame: .zero)
        trackForMemoryLeaks(subject)
    }

    func testConfigureTabAXLabel() {
        let cell = TabCell(frame: .zero)
        let state = testState1()
        cell.configure(with: state, theme: nil)
        XCTAssert(cell.accessibilityLabel!.contains(state.tabTitle))
    }

    func testConfigureTabAXHint() {
        let cell = TabCell(frame: .zero)
        let state = testState1()
        cell.configure(with: state, theme: nil)
        XCTAssertEqual(cell.accessibilityHint!,
                       String.TabTraySwipeToCloseAccessibilityHint)
    }

    func testConfigureTabSelectedState() {
        let cell = TabCell(frame: .zero)
        let state = testState1()
        cell.configure(with: state, theme: nil)
        XCTAssertEqual(cell.isSelectedTab,
                       state.isSelected)
    }
}
