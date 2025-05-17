import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var inputText = "Try saying [valley]uh huh[/valley] or [teen]hey you[/teen]!"
    @State private var pitch: Float = 1.2
    @State private var rate: Float = 0.5
    @State private var volume: Float = 1.0
    @State private var energy: Float = 0.5
    @State private var selectedVoice = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-US" }.first?.identifier ?? ""
    @State private var naturalMode = true
    @State private var useTags = true
    @State private var showEditor = false

    @State private var presets: [VoicePreset] = PresetManager.shared.load()
    @State private var selectedPresetID: UUID?
    @State private var newPresetName = ""

    let speechEngine = SpeechEngine()
    let tagParser = TagParser()
    @StateObject private var wordManager = WordToneManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    TextEditor(text: $inputText).frame(height: 160).border(Color.gray)

                    Toggle("Use Tags", isOn: $useTags)
                    Toggle("Natural Mode", isOn: $naturalMode)

                    Picker("Voice", selection: $selectedVoice) {
                        ForEach(AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-US" && $0.gender == .female }, id: \.identifier) { voice in
                            Text(voice.name).tag(voice.identifier)
                        }
                    }

                    SliderView(title: "Pitch", value: $pitch, range: 0.5...2.0)
                    SliderView(title: "Rate", value: $rate, range: 0.1...1.0)
                    SliderView(title: "Volume", value: $volume, range: 0.0...1.0)
                    SliderView(title: "Energy", value: $energy, range: 0.0...1.0)

                    HStack {
                        Button("Speak") {
                            let chunks = parseInput()
                            speechEngine.speak(chunks: chunks, voiceID: selectedVoice, energy: energy)
                        }
                        Button("Stop") {
                            speechEngine.stop()
                        }
                    }

                    Divider()

                    TextField("New Preset Name", text: $newPresetName).textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Save Preset") {
                        guard !newPresetName.isEmpty else { return }
                        let preset = VoicePreset(id: UUID(), name: newPresetName, voiceID: selectedVoice, pitch: pitch, rate: rate, volume: volume, energy: energy, naturalMode: naturalMode)
                        presets.append(preset)
                        PresetManager.shared.save(presets)
                        newPresetName = ""
                    }

                    Picker("Load Preset", selection: $selectedPresetID) {
                        Text("None").tag(UUID?.none)
                        ForEach(presets) { preset in
                            Text(preset.name).tag(Optional(preset.id))
                        }
                    }
                    .onChange(of: selectedPresetID) { id in
                        if let id = id, let preset = presets.first(where: { $0.id == id }) {
                            apply(preset)
                            PresetManager.shared.saveLastUsed(id: id)
                        }
                    }

                    Button("Open Word Tone Editor") {
                        showEditor.toggle()
                    }
                }
                .padding()
            }
            .navigationTitle("Speechy")
            .sheet(isPresented: $showEditor) {
                WordEditorView()
            }
        }
        .onAppear {
            if let id = PresetManager.shared.loadLastUsedID(),
               let last = presets.first(where: { $0.id == id }) {
                apply(last)
            }
        }
    }

    func apply(_ preset: VoicePreset) {
        selectedVoice = preset.voiceID
        pitch = preset.pitch
        rate = preset.rate
        volume = preset.volume
        energy = preset.energy
        naturalMode = preset.naturalMode
    }

    func parseInput() -> [SpeechChunk] {
        var chunks: [SpeechChunk] = []

        if useTags {
            chunks = tagParser.parse(text: inputText)
        } else {
            let words = inputText.split(separator: " ")
            chunks = words.map { word in
                let wordStr = String(word)
                if let tone = wordManager.tone(for: wordStr) {
                    return SpeechChunk(text: wordStr, pitch: tone.pitch, rate: tone.rate, volume: tone.volume)
                } else {
                    return SpeechChunk(text: wordStr, pitch: pitch, rate: rate, volume: volume)
                }
            }
        }

        return chunks
    }
}