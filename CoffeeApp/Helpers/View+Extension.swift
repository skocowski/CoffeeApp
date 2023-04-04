//
//  View+Extension.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 19/2/23.
//

import Foundation
import SwiftUI

extension View {
    
    func centerHorizontally() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
    
    func barTitle() -> some View {
        modifier(BarTitle())
    }
    
    func barValue() -> some View {
        modifier(BarValue())
    }
}


struct BarTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(.blue)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
    }
}

struct BarValue: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
    }
}
