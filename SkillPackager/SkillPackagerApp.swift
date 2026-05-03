//
//  SkillPackagerApp.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/04/30.
//

import SwiftUI
import SwiftData


/*
@main
struct SkillPackagerApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
      //  .modelContainer(sharedModelContainer)
    }
}
*/


 @main
 struct SkillComposerApp: App {
     @State private var model = SkillComposerModel()
     @State private var interface = InterfaceManager()
     
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environment(model)
                 .environment(interface)
         }
     }
 }
 
 
