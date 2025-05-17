import Foundation

struct VoicePreset: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let voiceID: String
    let pitch: Float
    let rate: Float
    let volume: Float
    let energy: Float
    let naturalMode: Bool
}