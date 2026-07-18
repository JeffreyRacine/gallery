import CoreGraphics
import Foundation

let requestedPID = CommandLine.arguments.dropFirst().first.flatMap(Int32.init)
let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
let windows =
    CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []

for window in windows {
    let pid = window[kCGWindowOwnerPID as String] as? Int32 ?? -1
    guard requestedPID == nil || requestedPID == pid else { continue }

    let id = window[kCGWindowNumber as String] as? Int ?? -1
    let owner = window[kCGWindowOwnerName as String] as? String ?? ""
    let name = window[kCGWindowName as String] as? String ?? ""
    let layer = window[kCGWindowLayer as String] as? Int ?? -1
    let alpha = window[kCGWindowAlpha as String] as? Double ?? -1
    let bounds = window[kCGWindowBounds as String] as? [String: Any] ?? [:]
    let x = bounds["X"] as? Double ?? -1
    let y = bounds["Y"] as? Double ?? -1
    let width = bounds["Width"] as? Double ?? -1
    let height = bounds["Height"] as? Double ?? -1

    print(
        "id=\(id) pid=\(pid) owner=\(owner) layer=\(layer) "
            + "alpha=\(alpha) bounds=\(x),\(y),\(width),\(height) name=\(name)"
    )
}
