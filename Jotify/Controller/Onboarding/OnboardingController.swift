//
//  OnboardingController.swift
//  Jotify
//
//  Created by Harrison Leath on 1/13/22.
//

import UIKit
import Pageboy
import Mixpanel

class OnboardingController: PageboyViewController, PageboyViewControllerDataSource {

    // MARK: Properties
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    //view controllers that will be displayed in page view controller.
    let vc1 = WelcomeViewOnboardingController()
    let vc2 = DetailOnboardingController(tText: "Improved UI", dText: "Tap the screen to start writing a note, and swipe left to right to access your saved notes. Jotify's user interface has been completely reimagined, and Jotify now supports widgets!", imgName: "Customization", finalVC: false)
    let vc3 = DetailOnboardingController(tText: "Instant Syncing", dText: "Jotify now syncs in real time! To accommodate this change, Jotify requires an account for all users, and you can use Sign in with Apple to keep your information private.", imgName: "Transfer", finalVC: false)
    let vc4 = DetailOnboardingController(tText: "Premium", dText: "To support the development of Jotify (and unlock great features), you can purchase premium. Or, you can refer 3 friends to get it for free! Thank you for your support!", imgName: "Referral", finalVC: true)
    
    private lazy var viewControllers: [UIViewController] = {
        return [self.vc1, self.vc2, self.vc3, self.vc4]
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set PageboyViewControllerDataSource dataSource to configure page view controller
        dataSource = self
        
        //remove bounce effect when overscrolling from page to page
        bounces = false
                
        //setup the color system for background with light/dark mode
        if traitCollection.userInterfaceStyle == .light {
            ColorManager.bgColor = .jotifyGray
        } else if traitCollection.userInterfaceStyle == .dark {
            if UserDefaults.standard.bool(forKey: "usePureDarkMode") {
                ColorManager.bgColor = .black
            } else {
                ColorManager.bgColor = .mineShaft
            }
        }
        
        view.backgroundColor = .clear
        
        // Track page view event
        Mixpanel.mainInstance().track(event: "page_view", properties: ["page_name": "Onboarding"])
    }

    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count //how many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index] //view controller to display at a specific index for the page view controller.
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .first
    }
    
    // MARK: Actions
    
    func scrollToNextPage() {
        scrollToPage(.next, animated: true)
    }
    
    // MARK: TraitCollection
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .light {
            ColorManager.bgColor = .jotifyGray
        } else if traitCollection.userInterfaceStyle == .dark {
            if UserDefaults.standard.bool(forKey: "usePureDarkMode") {
                ColorManager.bgColor = .black
            } else {
                ColorManager.bgColor = .mineShaft
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
