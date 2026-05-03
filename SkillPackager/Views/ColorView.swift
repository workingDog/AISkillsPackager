//
//  ColorView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import Foundation
import SwiftUI


struct ColorView: View {
    @Environment(InterfaceManager.self) var interface
    
    var body: some View {
        @Bindable var interface = interface
        VStack (spacing: 0) {
            HStack {
                Spacer()
                Button {
                    if interface.textSize < 13 {
                        interface.textSize = 12 // minimum size
                    } else {
                        interface.textSize -= 1
                    }
                } label: {
                    Image(systemName: "textformat.size.smaller")
                }
                Text("\(interface.textSize)").monospacedDigit()
                Button {
                    if interface.textSize > 31 {
                        interface.textSize = 32 // maximum size
                    } else {
                        interface.textSize += 1
                    }
                } label: {
                    Image(systemName: "textformat.size.larger")
                }
                Spacer()
            }.buttonStyle(.borderedProminent)
            
            HStack {
                ColorPicker("Colors", selection: Binding<Color>(
                    get: {
                        switch interface.selectedColor {
                            case .back: return interface.backColor
                            case .text: return interface.textColor
                            case .leftPanel: return interface.leftPanelColor
                            case .midPanel: return interface.midPanelColor
                            case .rightPanel: return interface.rightPanelColor
                            case .tools: return interface.toolsColor
                        }
                    },
                    set: {
                        switch interface.selectedColor {
                            case .back: interface.backColor = $0
                            case .text: interface.textColor = $0
                            case .leftPanel: interface.leftPanelColor = $0
                            case .midPanel: interface.midPanelColor = $0
                            case .rightPanel: interface.rightPanelColor = $0
                            case .tools: interface.toolsColor = $0
                        }
                    }
                ))
                .frame(width: 111, height: 40)
                .padding(10)
                Spacer()
                Toggle(isOn: $interface.isDarkMode) {
                    Text("Dark")
                }
                .frame(width: 130)
                .padding(.bottom, 10)
            }
            .padding(10)
            
            Picker("", selection: $interface.selectedColor) {
                Text("Back").tag(ColorType.back)
                Text("Text").tag(ColorType.text)
                Text("LeftPanel").tag(ColorType.leftPanel)
            }
            .pickerStyle(.segmented)
            
            Picker("", selection: $interface.selectedColor) {
                Text("MidPanel").tag(ColorType.midPanel)
                Text("RightPanel").tag(ColorType.rightPanel)
                Text("Tools").tag(ColorType.tools)
            }
            .pickerStyle(.segmented)
        }
    }
}

