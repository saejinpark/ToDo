import SwiftUI

struct StepEditor: View {
    @Binding var step: Step
    @State var temp = ""
    @FocusState private var isFocused: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Group {
            TextEditor(text: $temp)
                .focused($isFocused)
                .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    step.desc = temp
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            temp = step.desc
        }
    }
}
