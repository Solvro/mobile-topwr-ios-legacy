import SwiftUI
import NukeUI

public struct ContactView: View {
    private enum Constants {
        static let iconBackgroundSize: CGFloat = 35
    }
    let contact: Contact
    
    public init(
        contact: Contact
    ) {
        self.contact = contact
    }
    
    public var body: some View {
        HStack {
            ZStack {
                ZStack {
                    K.Colors.white
                        .cornerRadius(UIDimensions.small.cornerRadius)
                        .shadow()
                    #warning("TODO: Icon For contacts")
                }
                #warning("TODO: Contact link")
                Text(contact.number ?? "")
                    .foregroundColor(K.Colors.red)
                    .verticalPadding(.normal)
            }
        }
    }
}
