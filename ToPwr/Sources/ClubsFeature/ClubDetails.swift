//
//  File.swift
//  
//
//  Created by Jakub Legut on 20/12/2021.
//

import Foundation
import SwiftUI
import Common

public struct ClubDetailsView: View {
    let club: ClubCellState
    
    public init(
        club: ClubCellState
    ) {
        self.club = club
    }
    
    public var body: some View {
        ScrollView {
            VStack {
                ImageView(
                    url: URL(string: club.club.background?.url ?? ""),
                    contentMode: .aspectFill
                )
                    .frame(height: 300)
                
                ImageView(
                    url: URL(string: club.club.photo?.url ?? ""),
                    contentMode: .aspectFill
                )
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 7, x: 0, y: -5)
                    .offset(y: -60)
                    .padding(.bottom, -60)
                
                Text(club.club.name ?? "")
                    .font(.appBoldTitle2)
                    .horizontalPadding(.big)
                
                Text(club.club.locale)
                    .font(.appRegularTitle2)
                    .horizontalPadding(.huge)
                
                ZStack {
                    VStack {
                        Text(Strings.Other.deanOffice)
                            .font(.appBoldTitle2)
                    }
                    HStack {
                        Text(club.club.contact.first?.name ?? "")
                    }
                }
                .background(K.Colors.lightGray)
                
                HStack {
                    Spacer()
                    VStack {
                        
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
