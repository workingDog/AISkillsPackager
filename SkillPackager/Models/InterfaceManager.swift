//
//  InterfaceManager.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//

import Foundation
import SwiftUI


@Observable class InterfaceManager {
    
    // UI colors
    var backColor = Color.teal
    var textColor = Color.black
    
    var leftPanelColor = Color.green
    var midPanelColor = Color.blue
    var rightPanelColor = Color.red
    
    var toolsColor = Color.blue
    var selectedColor = ColorType.back
    
    var lang = "en"
    var isDarkMode = false
    var textSize: Int = 16
    
    
    init() {
        backColor = StoreService.getColor(ColorType.back)
        textColor = StoreService.getColor(ColorType.text)
        leftPanelColor = StoreService.getColor(ColorType.leftPanel)
        midPanelColor = StoreService.getColor(ColorType.midPanel)
        rightPanelColor = StoreService.getColor(ColorType.rightPanel)
        toolsColor = StoreService.getColor(ColorType.tools)
        
        lang = StoreService.getLang()
        isDarkMode = StoreService.getDisplayMode()
        textSize = StoreService.getTextSize()
    }

}

