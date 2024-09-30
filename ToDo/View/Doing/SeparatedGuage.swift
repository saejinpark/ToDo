import Foundation
import SwiftUI

struct SeparatedGaugeStyle: GaugeStyle {
    var limit: Int

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(1...limit, id: \.self) { index in
                    Rectangle()
                        .fill(index <= Int(round(configuration.value * Double(limit))) ? .black : Color(UIColor.systemGray4))
                        .cornerRadius(4)
                }
            }
        }
        .frame(height: 12)
    }
}

struct SeparatedGuage: View {
    var limit: Int
    var value: Int
    
    var body: some View {
        
        VStack(spacing: 20) {
            Gauge(value: Double(value), in: 0...Double(limit)) {
                Text("Progress")
            } currentValueLabel: {
                Text("\(value) / \(limit)")
            }
            .gaugeStyle(SeparatedGaugeStyle(limit: limit))
        }
    }
}

#Preview {
    SeparatedGuage(limit: 3, value: 1)
}
