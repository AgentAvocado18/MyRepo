import Foundation

struct WordTone: Codable, Identifiable {
    var id = UUID()
    var word: String
    var pitch: Float
    var rate: Float
    var volume: Float
}

class WordToneManager: ObservableObject {
    @Published var wordTones: [WordTone] = []

    init() {
        load()
    }

    func tone(for word: String) -> WordTone? {
        return wordTones.first { $0.word.lowercased() == word.lowercased() }
    }

    func save() {
        if let data = try? JSONEncoder().encode(wordTones) {
            UserDefaults.standard.set(data, forKey: "WordTones")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "WordTones"),
           let decoded = try? JSONDecoder().decode([WordTone].self, from: data) {
            wordTones = decoded
        }
    }

    func addOrUpdate(word: String, pitch: Float, rate: Float, volume: Float) {
        if let index = wordTones.firstIndex(where: { $0.word.lowercased() == word.lowercased() }) {
            wordTones[index] = WordTone(word: word, pitch: pitch, rate: rate, volume: volume)
        } else {
            wordTones.append(WordTone(word: word, pitch: pitch, rate: rate, volume: volume))
        }
        save()
    }

    func delete(_ tone: WordTone) {
        wordTones.removeAll { $0.id == tone.id }
        save()
    }
}