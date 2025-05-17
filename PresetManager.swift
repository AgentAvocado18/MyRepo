import Foundation

class PresetManager {
    static let shared = PresetManager()

    func save(_ presets: [VoicePreset]) {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: "SpeechyPresets")
        }
    }

    func load() -> [VoicePreset] {
        if let data = UserDefaults.standard.data(forKey: "SpeechyPresets"),
           let decoded = try? JSONDecoder().decode([VoicePreset].self, from: data) {
            return decoded
        }
        return []
    }

    func saveLastUsed(id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: "LastUsedPresetID")
    }

    func loadLastUsedID() -> UUID? {
        if let idString = UserDefaults.standard.string(forKey: "LastUsedPresetID") {
            return UUID(uuidString: idString)
        }
        return nil
    }
}