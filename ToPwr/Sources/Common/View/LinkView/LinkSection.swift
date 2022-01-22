import SwiftUI

public struct LinkSection: View {
    let title: String
    let links: [LinkComponent]
    
    public init(
        title: String,
        links: [LinkComponent?]
    ){
        self.title = title
        self.links = links.compactMap { $0 }
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.appBoldTitle2)
                        .horizontalPadding(.normal)
                    Spacer()
                }
                ForEach(links) { link in
                    LinkView(link: link)
                }
            }
        }
        .verticalPadding(.normal)
        .background(K.Colors.lightGray)
    }
}
