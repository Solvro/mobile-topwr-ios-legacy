//
//  File.swift
//  
//
//  Created by Jakub Legut on 20/12/2021.
//

import Foundation
import SwiftUI
import Common

public struct ClubCellView2: View {
    let club: ClubCellState
    
    public init(
        club: ClubCellState
    ) {
        self.club = club
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            K.CellColors.scienceBackground

            HStack {
                HStack() {
                    Text(club.club.name ?? "")
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, UIDimensions.normal.spacing)
                }
                HStack {
                    Spacer()
                    ZStack() {
                        ImageView(
                            url: URL(string: club.club.photo?.url ?? ""),
                            contentMode: .aspectFill
                        )
                        .frame(width: 90, height: 90)
                        .cornerRadius(8, corners: [.topRight, .bottomRight])
                    }
                }
            }
        }
        .frame(height: 92)
        .foregroundColor(K.CellColors.scienceBackground)
        .cornerRadius(8)
        .padding([.leading, .trailing])
    }
}
