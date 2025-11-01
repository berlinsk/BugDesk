import Foundation
import UniformTypeIdentifiers
import AVFoundation

func timestampString() -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return df.string(from: Date())
}

func guessMimeType(for url: URL) -> String {
    if let type = UTType(filenameExtension: url.pathExtension) {
        if type.conforms(to: .png) { return "image/png" }
        if type.conforms(to: .jpeg) { return "image/jpeg" }
        if type.conforms(to: .heic) { return "image/heic" }
        if type.conforms(to: .gif) { return "image/gif" }
        if type.conforms(to: .tiff) { return "image/tiff" }
        if type.conforms(to: .movie) || type.conforms(to: .mpeg4Movie) { return "video/mp4" }
        if type.conforms(to: .quickTimeMovie) { return "video/quicktime" }
    }
    return "application/octet-stream"
}

extension Collection where Element: RawRepresentable, Element.RawValue == String {
    var joinedRaw: String {
        let sorted = self.map { $0.rawValue }.sorted()
        if sorted.count > 1 {
            return sorted.map { "• \($0)" }.joined(separator: "\n")
        }
        return sorted.joined(separator: ", ")
    }
}
