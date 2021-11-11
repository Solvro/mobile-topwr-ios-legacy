import Foundation
import SwiftUI
import Common

//MARK: - View
public struct DaysToSessionView: View {
    private var sessionDay: SessionDay?
    private var date: Date?
    
    var days: Int {
        Calendar
            .current
            .dateComponents(
                [.day],
                from: Date(),
                to: date ?? Date()
            )
            .day!
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
    public init(
        session: SessionDay?
    ) {
        if session == nil {
            self.sessionDay = nil
            self.date = nil
        } else {
            self.sessionDay = session
            self.date = getDate(text: session?.sessionDate)
        }
    }
 
    public var body: some View {
        HStack {
            Spacer()
            ZStack {
                if sessionDay != nil {
                    HStack {
                        ZStack {
                            CounterView(
                                first: first,
                                second: second,
                                third: third
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("dni")
                            Text("do rozpoczęcia sesji")
                        }
                        .foregroundColor(K.Colors.white)
                    }
                    .padding()
                } else {
                    ProgressView()
                }
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
            Spacer()
        }
    }
}

extension DaysToSessionView {
    func getDate(text: String?) -> Date? {
        #warning("TODO: inject DateFormatter")
        guard let text = text else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: text)!
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

