//
//  ActionButtons.swift
//  Fardal
//
//  Created by Tobias Scholze on 19.12.23.
//

import SwiftUI

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

struct LargeAddButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.background)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor,lineWidth: 2)
                )
            
            Image(systemSymbol: .plus)
        }
    }
}



#Preview {
    VStack {
        Button("") {
            //
        }
        .buttonStyle(LargeAddButton())
        
        Divider()
        
        Button("") {
            //
        }
        .buttonStyle(BlueButton())
    }
}
