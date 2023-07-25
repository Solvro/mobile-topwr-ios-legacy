//
//  NewsComponent.swift
//  
//
//  Created by Mikolaj Zawada on 24/07/2023.
//

import Foundation

public class NewsComponent: Equatable, Identifiable {
    public static func == (lhs: NewsComponent, rhs: NewsComponent) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}

public final class ImageNewsComponent: NewsComponent {
    public let imageUrl: URL
    
    public init(imageUrl: URL, id: UUID = UUID()) {
        self.imageUrl = imageUrl
        super.init(id: id)
    }
}

public final class TextNewsComponent: NewsComponent {
    public let text: String
    
    public init(text: String, id: UUID = UUID()) {
        self.text = text
        super.init(id: id)
    }
}
