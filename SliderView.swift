import SwiftUI

struct SliderView: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>

    var body: some View {
        VStack {
            Text("\(title): \(String(format: "%.2f", value))")
            Slider(value: Binding(get: {
                Double(value)
            }, set: { newValue in
                value = Float(newValue)
            }), in: Double(range.lowerBound)...Double(range.upperBound))
        }
    }
}