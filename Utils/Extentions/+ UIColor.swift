//
//  + UIColor.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 22.05.2021.
//

import UIKit

extension UIColor {
    static let turquoise = #colorLiteral(red: 0.1354144812, green: 0.8831900954, blue: 0.6704884171, alpha: 1)
    static let lightPink = #colorLiteral(red: 1, green: 0.5129798055, blue: 0.7508437037, alpha: 1)
}

// MARK: Colors Cache
extension UIColor {
    
    private static var colorsCache: [String: UIColor] = [:]
    
    public static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, a: CGFloat) -> UIColor {
        let key = "\(r)\(g)\(b)\(a)"
        if let cachedColor = self.colorsCache[key] {
            return cachedColor
        }
        self.clearColorsCacheIfNeeded()
        let color = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
        self.colorsCache[key] = color
        return color
    }
    
    private static func clearColorsCacheIfNeeded() {
        let maxObjectsCount = 100
        guard self.colorsCache.count >= maxObjectsCount else { return }
        colorsCache = [:]
    }
}
