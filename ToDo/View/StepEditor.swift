import SwiftUI

struct StepEditor: View {
    @Binding var step: Step
    @FocusState private var isFocused: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Group {
            TextEditor(text: $step.desc)
                .focused($isFocused)
                .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    presentationMode.wrappedValue.dismiss()
                    modelContext.delete(step)
                } label: {
                    Label("Delete",systemImage: "trash.fill")
                }
            }
        }
        .onTapGesture {
            isFocused = false
        }
    }
}
