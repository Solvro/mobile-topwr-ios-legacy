import Foundation
import SwiftUI
import Common
import Strings

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
                               Strings.DaysToSessionView.days
                                   .font(.appBoldTitle3)
                               Strings.DaysToSessionView.tillStart
                                   .font(.appRegularTitle3)
                           }
                           .foregroundColor(K.Colors.white)
                           .padding(5)
                           
                           Spacer()
                       }
                       .padding()
                   } else {
                       HStack {
                           Spacer()
                           ProgressView()
                               .padding(20)
                           Spacer()
                       }
                   }
               }
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
    
    var width: CGFloat = 31
    var height: CGFloat = 42
    var fontSize: CGFloat = 20
    
    public var body: some View {
        HStack {
            ZStack {
                Text(first)
                    .font(.appBoldTitle1)
                    .foregroundColor(K.FontColors.primary)
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(4)
            .shadow(radius: 2, y: 2)
            
            ZStack {
                Text(second)
                    .font(.appBoldTitle1)
                    .foregroundColor(K.FontColors.primary)
                
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(4)
            .shadow(radius: 2, y: 2)
            
            
            ZStack {
                Text(third)
                    .font(.appBoldTitle1)
                    .foregroundColor(K.FontColors.primary)
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(4)
            .shadow(radius: 2, y: 2)
        }
    }
}

