import Foundation
import Mixpanel

class MixpanelManager {
    static let shared = MixpanelManager()
    
    private init() {}
    
    func initialize() {
        Mixpanel.initialize(token: "c9e30f942625129799e00561b5a0d539", trackAutomaticEvents: true)
    }
    
    func identify(userId: String) {
        Mixpanel.mainInstance().identify(distinctId: userId)
    }
    
    func setUserProperties(properties: [String: MixpanelType]) {
        Mixpanel.mainInstance().people.set(properties: properties)
    }
    
    func track(event: String, properties: [String: MixpanelType]? = nil) {
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }
    
    func reset() {
        Mixpanel.mainInstance().reset()
    }
}
