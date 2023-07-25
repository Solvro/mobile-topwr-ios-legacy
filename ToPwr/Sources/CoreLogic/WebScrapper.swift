//
//  WebScrapper.swift
//  
//
//  Created by Mikolaj Zawada on 22/07/2023.
//

import Foundation
import Common
import SwiftSoup

public enum WebScrapperError: Error {
    case dataDecoding
    case newsParsing
}

public enum URLProperties {
    static let baseUrl = "https://pwr.edu.pl"
}

final public class NewsWebScrapper {
    
    public static let shared: NewsWebScrapper = .init()
    
    private init() {}
    
    public func getWhatsNew(numberOfPages: Int = 3) async throws -> [WhatsNew] {
        precondition(2...420 ~= numberOfPages, "Number of pages must be within the available range 2-420")
        let urlString = URLProperties.baseUrl + "/uczelnia/aktualnosci"
        let url = URL(string: urlString)!
        
        var news: [WhatsNew] = try await extractWhatsNew(url: url)
        
        for pageNumber in 2...numberOfPages {
            if let moreNews = try? await extractWhatsNew(url: URL(string: urlString+pageUrl(number: pageNumber))!) {
                news.append(contentsOf: moreNews)
            }
        }
        return news
    }
    
    private func extractWhatsNew(url: URL) async throws -> [WhatsNew] {
        let (htmlResponse, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: htmlResponse, encoding: .utf8) else {
            throw WebScrapperError.dataDecoding
        }
        
        var news: [WhatsNew] = []
        
        let doc: Document = try SwiftSoup.parse(html)
        let newsBoxes = try doc.select("div.news-box")
        
        for newsBox in newsBoxes.array() {
            let imgUrl = try newsBox.select("div.col-img img").attr("src")
            let title = try newsBox.select("a.title").text()
            let paragraphs: Elements = try newsBox.select("div.col-text.text-content").select("p")
            let imageURL = URL(string: URLProperties.baseUrl + imgUrl)
            let detailsURL = try? newsBox.select("a").first()?.attr("href")
            
            news.append(WhatsNew(
                id: UUID(),
                title: title,
                description: try paragraphs.array()[1].text(),
                infoSection: [],
                photo: imageURL != nil ? .init(url: imageURL!) : nil,
                detailsUrl: detailsURL != nil ? URL(string: URLProperties.baseUrl + detailsURL!) : nil
            ))
        }
        
        return news
    }
    
    private func pageUrl(number: Int) -> String {
        "/page\(number).html"
    }
    
    public func getNewsDetails(url: URL) async throws -> [NewsComponent] {
        let (htmlResponse, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: htmlResponse, encoding: .utf8) else {
            throw WebScrapperError.dataDecoding
        }
        
        let doc: Document = try SwiftSoup.parse(html)
        let newsParagraphs = try doc.select("div.text").select("p")
        
        var components: [NewsComponent] = []
        
        for paragraph in newsParagraphs {
            if let imageUrl = try? paragraph.select("img").first()?.attr("src"),
               let safeUrl = URL(string: imageUrl) {
                components.append(ImageNewsComponent(imageUrl: safeUrl))
            }
            components.append(TextNewsComponent(text: try paragraph.text(trimAndNormaliseWhitespace: true)))
        }
        
        return components
    }
}

