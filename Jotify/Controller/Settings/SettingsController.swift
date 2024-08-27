//
//  SettingsController.swift
//  Jotify
//
//  Created by Harrison Leath on 2/1/21.
//

import UIKit
import Mixpanel

//superclass for all settings controllers
class SettingsController: UITableViewController {
    //number of sections found in each VC
    var sections: [String] = []
    var section1: [String] = []
    var section2: [String] = []
    var section3: [String] = []
    
    var noteCollection: NoteCollection?
    
    override func viewWillAppear(_ animated: Bool) {
        enableAutomaticStatusBarStyle()
        navigationController?.configure(bgColor: ColorManager.bgColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fixes issue where tableview becomes unresponsive when disabling swipe
        tableView.contentInset = .zero
        tableView.isUserInteractionEnabled = true
        tableView.isScrollEnabled = true
        
        view.backgroundColor = ColorManager.bgColor
                
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SettingsSwitchCell.self, forCellReuseIdentifier: "SettingsSwitchCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Track page view event
        Mixpanel.mainInstance().track(event: "page_view", properties: ["page_name": "Settings"])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section1.count
        case 1:
            return section2.count
        case 2:
            return section3.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        enableAutomaticStatusBarStyle()
        view.backgroundColor = ColorManager.bgColor
        navigationController?.configure(bgColor: ColorManager.bgColor)
        
        var color = UIColor.white
        if traitCollection.userInterfaceStyle == .light || traitCollection.userInterfaceStyle == .unspecified { color = .black }
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : color]
    }
}
