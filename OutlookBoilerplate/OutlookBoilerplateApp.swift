//
//  OutlookBoilerplateApp.swift
//  OutlookBoilerplate
//

import OutlookBackdrop
import SwiftUI

@main
struct OutlookBoilerplateApp: App {
    init() {
        OutlookBackdrop.applyToFluentTheme()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
