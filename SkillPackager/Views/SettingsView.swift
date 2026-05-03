//
//  SettingsView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import Foundation
import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(InterfaceManager.self) var interface
    

    var body: some View {
        ZStack {
            interface.backColor
            ScrollView {
                VStack (alignment: .leading, spacing: 15) {
                    
                    HStack {
                        Button("Done") {
                            dismiss()
                        }.padding(8)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    ColorView()
                    
                    Spacer()
                }
                .padding(8)
            }
        }
        .preferredColorScheme(interface.isDarkMode ? .dark : .light)
        .environment(\.locale, Locale(identifier: interface.lang))
        .onDisappear {
            doSave()
        }
    }
    
    func doSave() {
        StoreService.setColor(ColorType.back, color: interface.backColor)
        StoreService.setColor(ColorType.text, color: interface.textColor)
        StoreService.setColor(ColorType.question, color: interface.questionColor)
        StoreService.setColor(ColorType.answer, color: interface.answerColor)
        StoreService.setColor(ColorType.copy, color: interface.copyColor)
        StoreService.setColor(ColorType.tools, color: interface.toolsColor)
        StoreService.setLang(interface.lang)
        StoreService.setDisplayMode(interface.isDarkMode)
        StoreService.setTextSize(interface.textSize)
        
        dismiss()
    }
    
}
