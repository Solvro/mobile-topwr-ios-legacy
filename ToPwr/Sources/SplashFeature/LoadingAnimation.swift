//
//  SwiftUIView.swift
//  
//
//  Created by Mikolaj Zawada on 19/02/2022.
//

import SwiftUI
import PureSwiftUI
import Common
import ClubsFeature

struct LoadingAnimation: View {
    enum Constants {
        static let rotationTime: Double = 0.75
        static let fullRotation: Angle = .degrees(360)
        static let animationTime = 1.5
        static let initialDegree: Angle = .degrees(270)
        static let largeCircleFrame: CGSize = CGSize(width: 100, height: 100)
        static let mediumCircleFrame: CGSize = CGSize(width: 70, height: 70)
        static let smallCircleFrmae: CGSize = CGSize(width: 40, height: 40)
    }
    
    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.0
    @State var rotationDegreeS1: Angle = .degrees(270)
    
    var body: some View {
        ZStack {
            SubCircle(
                color: K.Colors.firstColorDark,
                start: spinnerStart,
                end: spinnerEndS1,
                rotation: rotationDegreeS1,
                lineWidth: 10
            )
                .frame(Constants.largeCircleFrame)
            SubCircle(
                color: K.Colors.logoBlue,
                start: spinnerStart,
                end: spinnerEndS1,
                rotation: rotationDegreeS1,
                lineWidth: 10
            )
                .frame(Constants.mediumCircleFrame)
                .rotate3D(Angle(degrees: 180), (1,0,0))
            SubCircle(
                color: K.Colors.firstGreen,
                start: spinnerStart,
                end: spinnerEndS1,
                rotation: rotationDegreeS1,
                lineWidth: 10
            )
                .frame(Constants.smallCircleFrmae)
        }.onAppear {
            Timer.scheduledTimer(withTimeInterval: Constants.animationTime, repeats: true) { (mainTimer) in
                self.animateSpinner()
            }
        }
    }
    
    private struct SubCircle: View {
        var color: Color
        var start: CGFloat
        var end: CGFloat
        var rotation: Angle
        var lineWidth: Int
        
        var body: some View {
            Circle()
                .trim(from: start, to: end)
                .stroke(style: StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .round))
                .fill(color)
                .rotationEffect(rotation)
        }
    }
    
    private func animateSpinner(with timeInterval: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: Constants.rotationTime)) {
                completion()
            }
        }
    }
    
    private func animateSpinner() {
        animateSpinner(with: Constants.rotationTime) {
            self.spinnerEndS1 = 1.0
        }
        animateSpinner(with: Constants.rotationTime * 2) {
            self.rotationDegreeS1 += Constants.fullRotation
        }
        animateSpinner(with: Constants.rotationTime * 2) {
            self.spinnerEndS1 = 0.01
        }
    }
}

struct LoadingAnimation_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimation()
    }
}
