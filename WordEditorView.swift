import SwiftUI

struct WordEditorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = WordToneManager()

    @State private var word = ""
    @State private var pitch: Float = 1.2
    @State private var rate: Float = 0.5
    @State private var volume: Float = 1.0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add / Edit Word Tone")) {
                    TextField("Word", text: $word)
                    SliderView(title: "Pitch", value: $pitch, range: 0.5...2.0)
                    SliderView(title: "Rate", value: $rate, range: 0.1...1.0)
                    SliderView(title: "Volume", value: $volume, range: 0.0...1.0)

                    Button("Save") {
                        guard !word.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        manager.addOrUpdate(word: word, pitch: pitch, rate: rate, volume: volume)
                        word = ""
                    }
                }

                Section(header: Text("Saved Word Tones")) {
                    ForEach(manager.wordTones) { tone in
                        VStack(alignment: .leading) {
                            Text(tone.word.capitalized)
                            Text("Pitch: \(tone.pitch), Rate: \(tone.rate), Volume: \(tone.volume)").font(.caption)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                manager.delete(tone)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Word Tone Editor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}