import Foundation

class TagParser {
    let styles: [String: (Float, Float, Float)] = [
        "emph": (1.4, 0.5, 1.0),
        "pause": (1.0, 0.1, 1.0),
        "slow": (1.0, 0.3, 1.0),
        "loud": (1.0, 0.5, 1.0),
        "soft": (1.0, 0.5, 0.4),
        "high": (1.7, 0.5, 1.0),
        "low": (0.8, 0.5, 1.0),
        "excited": (1.6, 0.6, 1.0),
        "valley": (1.5, 0.7, 1.0),
        "waifu": (1.8, 0.5, 0.8),
        "bimbo": (1.9, 0.45, 1.0),
        "teen": (1.6, 0.6, 1.0),
        "brat": (1.7, 0.55, 1.0),
        "vflirt": (1.8, 0.65, 1.0),
        "uhhuh": (1.8, 0.6, 1.0)
    ]

    func parse(text: String) -> [SpeechChunk] {
        var chunks: [SpeechChunk] = []
        let regex = try! NSRegularExpression(pattern: "\\[(\\w+)\\](.+?)\\[/\\1\\]", options: [])
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        var lastEnd = text.startIndex
        for match in matches {
            let tagRange = Range(match.range(at: 1), in: text)!
            let textRange = Range(match.range(at: 2), in: text)!
            let tag = String(text[tagRange])
            let taggedText = String(text[textRange])

            // Add plain text before match
            if lastEnd < tagRange.lowerBound {
                let before = String(text[lastEnd..<tagRange.lowerBound])
                if !before.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    chunks.append(SpeechChunk(text: before, pitch: 1.2, rate: 0.5, volume: 1.0))
                }
            }

            if let style = styles[tag] {
                chunks.append(SpeechChunk(text: taggedText, pitch: style.0, rate: style.1, volume: style.2))
            }

            lastEnd = Range(match.range, in: text)!.upperBound
        }

        // Remaining text
        if lastEnd < text.endIndex {
            let trailing = String(text[lastEnd...])
            if !trailing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                chunks.append(SpeechChunk(text: trailing, pitch: 1.2, rate: 0.5, volume: 1.0))
            }
        }

        return chunks
    }
}