//
//  AnalyticsManager.swift
//  Jotify
//
//  Created by Harrison Leath on 3/7/21.
//

import FirebaseAnalytics
import UIKit
import Mixpanel

class AnalyticsManager {
    
    static func logEvent(named: String, description: String) {
        Analytics.logEvent(named, parameters: [
            "description" : description
        ])
        
        // Track event in Mixpanel
        Mixpanel.mainInstance().track(event: named, properties: [
            "description": description
        ])
    }
}
