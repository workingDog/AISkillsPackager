//
//  StoreService.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//

import Foundation
import SwiftUI


enum ColorType: String, CaseIterable {
    case back, text, question, answer, copy, tools
}

class StoreService {
    
    static func setColor(_ key: ColorType, color: Color) {
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: NSColor(color), requiringSecureCoding: false)
            UserDefaults.standard.set(colorData, forKey: "ringow.com.composer.color.\(key.rawValue)")
        } catch {
            print("in StoreService setColor error: \(error)")
        }
    }
    
    static func getColor(_ key: ColorType) -> Color {
        do {
            if let colorData = UserDefaults.standard.data(forKey: "ringow.com.composer.color.\(key.rawValue)"),
               let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
                return Color(nsColor: nsColor)
            }
        } catch {
            print("in StoreService getColor error: \(error)")
        }
        switch key {
            case ColorType.back: return Color.teal
            case ColorType.text: return Color.white
            case ColorType.question: return Color.green
            case ColorType.answer: return Color.blue
            case ColorType.copy: return Color.red
            case ColorType.tools: return Color.blue
        }
    }
    
    static func getLang() -> String {
        return UserDefaults.standard.string(forKey: "ringow.com.composer.defaultlang.key") ?? "en"
    }
    
    static func setLang(_ str: String) {
        UserDefaults.standard.set(str, forKey: "ringow.com.composer.defaultlang.key")
    }
    
    static func getDisplayMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "ringow.com.composer.displaymode.key")
    }
    
    static func setDisplayMode(_ isDark: Bool) {
        UserDefaults.standard.set(isDark, forKey: "ringow.com.composer.displaymode.key")
    }

    static func getTextSize() -> Int {
        return UserDefaults.standard.integer(forKey: "ringow.com.composer.textsize.key")
    }
    
    static func setTextSize(_ val: Int) {
        UserDefaults.standard.set(val, forKey: "ringow.com.composer.textsize.key")
    }
    
}

