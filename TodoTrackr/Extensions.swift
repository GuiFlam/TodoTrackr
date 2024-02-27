//
//  DateExtension.swift
//  TaskScribe
//
//  Created by GuiFlam on 2024-02-22.
//

import Foundation
import SwiftUI

extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Color {
    init(hex: String) {
        // Remove '#' character if present
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        // Convert hex string to an integer
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        // Create UIColor from the integer
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        // Initialize Color with UIColor
        self.init(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
    }
}

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }

}
