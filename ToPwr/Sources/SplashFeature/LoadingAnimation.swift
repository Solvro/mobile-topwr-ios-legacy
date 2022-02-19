//
//  SwiftUIView.swift
//  
//
//  Created by Mikolaj Zawada on 19/02/2022.
//

import SwiftUI
import PureSwiftUI

struct LoadingAnimation: View { // create custom init
    let rotationTime: Double = 0.75
    let fullRotation: Angle = .degrees(360)
    let animationTime = 1.5
    static let initialDegree: Angle = .degrees(270)
    
    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.0
    @State var rotationDegreeS1 = initialDegree
    
    var body: some View {
        ZStack {
            SubCircle(color: .blue, start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, lineWidth: 10)
                .frame(100,100)
            SubCircle(color: .red, start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, lineWidth: 10)
                .frame(70,70)
                .rotate3D(Angle(degrees: 180), (1,0,0))
            SubCircle(color: .green, start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, lineWidth: 10)
                .frame(40,40)
        }.onAppear {
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { (mainTimer) in
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
            withAnimation(Animation.easeInOut(duration: rotationTime)) {
                completion()
            }
        }
    }
    
    private func animateSpinner() {
        animateSpinner(with: rotationTime) {
            self.spinnerEndS1 = 1.0
        }
        animateSpinner(with: rotationTime * 2) {
            self.rotationDegreeS1 += fullRotation
        }
        animateSpinner(with: rotationTime * 2) {
            self.spinnerEndS1 = 0.01
        }
    }
    
}

struct LoadingAnimation_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimation()
    }
}
