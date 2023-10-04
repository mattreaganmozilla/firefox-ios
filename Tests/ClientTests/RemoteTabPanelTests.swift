// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Storage
import Shared
import XCTest

@testable import Client

final class RemoteTabPanelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DependencyHelperMock().bootstrapDependencies()
    }

    override func tearDown() {
        super.tearDown()
        DependencyHelperMock().reset()
    }

    func testTableView_emptyStateNoRows() {
        let remotePanel = createSubject(state: generateEmptyState())
        let tableView = remotePanel.tableViewController.tableView

        XCTAssertNotNil(tableView)
        XCTAssertEqual(tableView!.numberOfSections, 0)
    }

    func testTableView_oneClientTwoRows() {
        let remotePanel = createSubject(state: generateStateOneClientTwoTabs())
        let tableView = remotePanel.tableViewController.tableView

        XCTAssertNotNil(tableView)
        XCTAssertEqual(tableView!.numberOfSections, 1)
        XCTAssertEqual(tableView!.numberOfRows(inSection: 0), 2)
    }

    // MARK: - Private

    private func generateEmptyState() -> RemoteTabsPanelState {
        return RemoteTabsPanelState.emptyState()
    }

    private func generateStateOneClientTwoTabs() -> RemoteTabsPanelState {
        let fakeTabs: [RemoteTab] = [RemoteTab(clientGUID: "123", URL: URL(string: "https://mozilla.com")!, title: "Mozilla Homepage", history: [], lastUsed: 0, icon: nil), RemoteTab(clientGUID: "123", URL: URL(string: "https://google.com")!, title: "Google Homepage", history: [], lastUsed: 0, icon: nil)]
        let fakeData: [ClientAndTabs] = [ClientAndTabs(client: RemoteClient(guid: "123", name: "Test Client", modified: 0, type: "Test Type", formfactor: "Test", os: "Test", version: "v1.0", fxaDeviceId: "12345"), tabs: fakeTabs)]
        return RemoteTabsPanelState(refreshState: .loaded,
                                    clientAndTabs: fakeData,
                                    allowsRefresh: true,
                                    showingEmptyState: nil,
                                    syncIsSupported: true)
    }

    private func createSubject(state: RemoteTabsPanelState,
                               file: StaticString = #file,
                               line: UInt = #line) -> RemoteTabsPanel {
        let subject = RemoteTabsPanel(state: state)

        trackForMemoryLeaks(subject, file: file, line: line)
        return subject
    }
}