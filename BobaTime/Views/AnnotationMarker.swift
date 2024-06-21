import SwiftUI

struct AnnotationMarker: View {
    var name: String
    @State var isSelected = false
    
    var body: some View {
        
        Button(action: {isSelected.toggle()}, label: {
            VStack {
                if isSelected {
                    Text(name)
                        .foregroundColor(Color.black)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .background(Color.yellow)
                        .fixedSize()
                }
               
                Image(systemName: "pin.circle.fill").foregroundColor(isSelected ? .red : .purple)
            }
        })
    }
}

struct AnnotationMarker_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationMarker(name: "ABC Tea")
    }
}
