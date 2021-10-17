import Foundation
import SwiftUI
import Common

//MARK: - Session struct
private struct SessionDay {
    var sessionDate: Date
    
    public init(
        date: Date
    ) {
        sessionDate = date
    }
    
    var days: Int {
        return Date().daysBetween(start: Date(), end: sessionDate)
    }
    
    var first: String {
        if days >= 100 {
            return "\(days/100)"
        } else {
            return "0"
        }
    }
    
    var second: String {
        if days >= 10 && days < 100 {
            return "\(days/10)"
        } else if days >= 100 {
            return "\((days % 100)/10)"
        } else {
            return "0"
        }
    }
    
    var third: String {
        return "\(days % 10)"
    }
}

//MARK: - View
public struct DaysToSessionView: View {
    private var sessionDate: SessionDay
    
    public init(
        sessionDate: Date
    ) {
        self.sessionDate = .init(date: sessionDate)
    }
 
    public var body: some View {
        ZStack {
            HStack {
                ZStack {
                    CounterView(
                        first: sessionDate.first,
                        second: sessionDate.second,
                        third: sessionDate.third
                    )
                }
                
                VStack(alignment: .leading) {
                    Text("dni")
                        .foregroundColor(K.Colors.white)
                        .fontWeight(.bold)
                    Text("do rozpoczęcia sesji")
                        .foregroundColor(K.Colors.white)
                }
            }
            .padding()
        }
        .frame(width: 340, height: 80)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        K.Colors.firstColorLight,
                        K.Colors.firstColorDark
                    ]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(10)
    }
}


//Counter View - showing numbers only
private struct CounterView: View {
    var first: String
    var second: String
    var third: String
    
    var width: CGFloat = 37
    var height: CGFloat = 47
    var fontSize: CGFloat = 24
    
    public var body: some View {
        HStack {
            ZStack {
                Text(first)
                    .font(.system(size: fontSize))
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(3)
            .shadow(radius: 2, y: 2)
            
            ZStack {
                Text(second)
                    .font(.system(size: fontSize))
                
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(3)
            .shadow(radius: 2, y: 2)
            
            
            ZStack {
                Text(third)
                    .font(.system(size: fontSize))
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(4)
            .shadow(radius: 2, y: 2)
        }
    }
}

