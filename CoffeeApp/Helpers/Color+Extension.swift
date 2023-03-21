//
//  Color+Extension.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 20/2/23.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let value = Color("value")
    let universal = Color("universal")
    let background = Color("background")
    let tabFontLight = Color("tabFontLight")
    let tabFontDark = Color("tabFontDark")
    let tabBackground = Color("tabBackground")
    let suggestionsBackground = Color("suggestionsBackground")
}
