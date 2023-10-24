// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class AppDataUsageReportSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "App Data Usage Report", attributes: [NSAttributedString.Key.foregroundColor: theme.colors.textPrimary])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let results = generateAppDataSummary()
        UIPasteboard.general.string = results

        // Hidden debug utility not localized for now.
        showSimpleAlert("Summary generated. Text has been copied to the clipboard.")
    }

    // MARK: - Internal Utilities

    private func showSimpleAlert(_ message: String) {
        let alert = UIAlertController(title: "App Data Usage",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        settings.present(alert, animated: true)
    }

    private func generateAppDataSummary() -> String {
        var directoriesAndSizes: [String: UInt64] = [:]
        var largeFileWarnings: [String: UInt64] = [:]
        let fileManager = FileManager.default
        let warningSize = 100 * 1024 * 1024  // (100MB) File size threshold to log for report

        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let directories: [URL] = [cachesDirectory, documentsDirectory].compactMap({ $0 })

        for baseDirectory in directories {
            guard let enumerator = fileManager.enumerator(at: baseDirectory,
                                                          includingPropertiesForKeys: [URLResourceKey.fileSizeKey],
                                                          options: [],
                                                          errorHandler: nil) else { continue }
            for case let fileURL as URL in enumerator {
                var isDir: ObjCBool = false
                let path = fileURL.path
                if fileManager.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue {
                    let parentDir = fileURL.deletingLastPathComponent().path
                    if directoriesAndSizes[parentDir] == nil { directoriesAndSizes[parentDir] = 0 }
                    do {
                        let values = try fileURL.resourceValues(forKeys: [URLResourceKey.fileSizeKey])
                        let size = UInt64(values.fileSize ?? 0)

                        if size >= warningSize { largeFileWarnings[path] = size }

                        // Find any directory whose path is a valid prefix for the file path
                        // This allows us to tally the total sizes for parent directories
                        // along with nested children (if needed) at the same time.
                        for dir in directoriesAndSizes.keys where path.hasPrefix(dir) {
                            let newSize = (directoriesAndSizes[dir] ?? 0) + size
                            directoriesAndSizes[dir] = newSize
                        }
                    } catch {
                        print("Error checking file size: \(error)")
                    }
                } else {
                    if directoriesAndSizes[path] == nil { directoriesAndSizes[path] = 0 }
                }
            }
        }

        let directoriesAndSizesSorted = directoriesAndSizes
            .map({ return ($0, $1) })
            .sorted(by: { return $0.1 > $1.1 })

        var result = "FireFox Debug Utility: App Data Summary"
        result += "\n======================================="
        result += "\n"
        for (dir, size) in directoriesAndSizesSorted {
            result += "\nSize: \(size / 1024) kb \t\tDirectory: \t\(dir)"
        }
        result += "\n\n======================================="
        result += "\nLarge files detected: \(largeFileWarnings.count)"
        for (file, size) in largeFileWarnings {
            result += "\nSize: \(size / 1024) kb \t\tFile: \t\(file)"
        }
        return result
    }
}
