//
//  UIColor+Theme.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

extension UIColor {
    struct Theme {
        static var main: UIColor  { return UIColor(named: "Main")! }
    }
    
    static var random: UIColor {
        let r = CGFloat.random(in: 0...255) / 255.0
        let g = CGFloat.random(in: 0...255) / 255.0
        let b = CGFloat.random(in: 0...255) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
