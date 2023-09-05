//
//  RadialMenu.swift
//  NewNotes
//
//  Created by andreasara-dev on 26/07/23.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(.callout)
            .background(Color.blue.opacity(configuration.isPressed ? 0.5 : 1))
            .clipShape(Circle())
            .foregroundColor(.white)
    }
}

struct RadialButton {
    let label: String
    let image: Image
    let action: () -> Void
}

struct RadialMenu: View {
    @State private var isExpanded = false
    @State private var isShowingSheet = false
    
    let title: String
    let closedImage: Image
    let openImage: Image
    let buttons: [RadialButton]
    var direction = Angle(degrees: 315)
    var range = Angle(degrees: 90)
    var distance = 100.0
    var animation = Animation.default
    
    var body: some View {
        ZStack {
            Button {
                if UIAccessibility.isVoiceOverRunning {
                    isShowingSheet.toggle()
                } else {
                    isExpanded.toggle()
                }
            } label: {
                isExpanded ? openImage : closedImage
            }
            .accessibilityLabel(Text(title))
            
            ForEach(0..<buttons.count, id: \.self) { i in
                Button {
                    buttons[i].action()
                    isExpanded.toggle()
                } label: {
                    buttons[i].image
                }
                .accessibilityHidden(isExpanded == false)
                .accessibilityLabel(Text(buttons[i].label))
                .offset(offset(for: i))
            }
            .opacity(isExpanded ? 1 : 0)
            .animation(animation, value: isExpanded)
        }
        .actionSheet(isPresented: $isShowingSheet) {
            ActionSheet(title: Text(title), message: nil, buttons: buttons.map { btn in
                ActionSheet.Button.default(Text(btn.label), action: btn.action)
            } + [.cancel()]
            )
        }
    }
    
    func offset(for index: Int) -> CGSize {
        guard isExpanded else { return .zero }
        
        let buttonAngle = range.radians / Double(buttons.count - 1)
        let ourAngle = buttonAngle * Double(index)
        let finalAngle = direction - (range / 2) + Angle(radians: ourAngle)
        
        let finalX = cos(finalAngle.radians - .pi / 2) * distance
        let finalY = sin(finalAngle.radians - .pi / 2) * distance
        return CGSize(width: finalX, height: finalY)
    }
}
