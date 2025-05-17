import Foundation
import AVFoundation

class SpeechEngine {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(chunks: [SpeechChunk], voiceID: String, energy: Float) {
        synthesizer.stopSpeaking(at: .immediate)

        for chunk in chunks {
            let utterance = AVSpeechUtterance(string: chunk.text)
            utterance.voice = AVSpeechSynthesisVoice(identifier: voiceID)
            utterance.pitchMultiplier = chunk.pitch + energy * 0.2
            utterance.rate = chunk.rate
            utterance.volume = chunk.volume

            // Special handling for inflection tone (e.g. uhhuh)
            if chunk.text.lowercased() == "uh huh" {
                utterance.pitchMultiplier += 0.3
                utterance.rate += 0.1
            }

            utterance.postUtteranceDelay = 0.05
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}