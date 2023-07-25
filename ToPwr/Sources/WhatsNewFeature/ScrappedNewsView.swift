//
//  ScrappedNewsView.swift
//  
//
//  Created by Mikolaj Zawada on 24/07/2023.
//

import Foundation
import SwiftUI
import Common

struct ScrappedNewsView: View {
    
    let news: [NewsComponent]
    
    var numberOfImageComponents: Int { news.filter { $0 is ImageNewsComponent }.count }

    @State var imageLoadResponseIndex = 0 {
        didSet {
            if imageLoadResponseIndex == numberOfImageComponents {
                isLoadingImages = false
            }
        }
    }
    
    @State var isLoadingImages = true
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(news) { component in
                        switch component {
                        case is ImageNewsComponent:
                            displayImage(component: component)
                        case is TextNewsComponent:
                            displayText(component: component)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
            
            // Experimental solution to display news only when all images loaded
            
            if isLoadingImages {
                ZStack {
                    Color.white
                    
                    VStack {
                        Spacer()
                        
                        ProgressView()
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func displayImage(component: NewsComponent) -> AnyView {
        guard let imageComponent = component as? ImageNewsComponent else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            AsyncImage(url: imageComponent.imageUrl) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .onAppear {
                            imageLoadResponseIndex += 1
                        }
                } else if phase.error != nil {
                    EmptyView()
                        .onAppear {
                            imageLoadResponseIndex += 2
                        }
                } else {
                    EmptyView()
                }
            }
                .padding(.horizontal)
        )
    }
    
    private func displayText(component: NewsComponent) -> AnyView {
        guard let textComponent = component as? TextNewsComponent else {
            return AnyView(EmptyView())
        }
        return AnyView(
            Text(textComponent.text)
                .font(.appMediumTitle3)
                .padding(.horizontal)
        )
    }
}
