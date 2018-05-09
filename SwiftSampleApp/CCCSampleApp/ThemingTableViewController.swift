/*
 
 Copyright (c) 2017 iMobile3, LLC. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, is permitted provided that adherence to the following
 conditions is maintained. If you do not agree with these terms,
 please do not use, install, modify or redistribute this software.
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY IMOBILE3, LLC "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL IMOBILE3, LLC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

import UIKit
import CardConnectConsumerSDK

class ThemingTableViewController: UITableViewController {

    var theme: CCCTheme?
    
    var navigationBarColor: UIColor?
    var navigationTitleColor: UIColor?
    var navigationButtonColor: UIColor?
    var backgroundColor: UIColor?
    var disclaimerTextColor: UIColor?
    var buttonColor: UIColor?
    var buttonTextColor: UIColor?
    var spinnerBackgroundColor: UIColor?
    var listSeparatorColor: UIColor?
    var listCellColor: UIColor?
    var listTextColor: UIColor?
    var listSecondaryTextColor: UIColor?
    var listSectionHeaderColor: UIColor?
    var cardColor: UIColor?
    var cardTextColor: UIColor?
    var listInputTextColor: UIColor?
    var listToggleOnColor: UIColor?
    var listToggleTintColor: UIColor?
    var listToggleThumbColor: UIColor?
    
    var valueKeys: Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed)),
                                                   UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetPressed))]
        
        self.valueKeys = ["navigationBarColor",
                          "navigationTitleColor",
                          "navigationButtonColor",
                          "backgroundColor",
                          "disclaimerTextColor",
                          "buttonColor",
                          "buttonTextColor",
                          "spinnerBackgroundColor",
                          "listSeparatorColor",
                          "listCellColor",
                          "listTextColor",
                          "listSecondaryTextColor",
                          "listSectionHeaderColor",
                          "cardColor",
                          "cardTextColor",
                          "listInputTextColor",
                          "listToggleOnColor",
                          "listToggleTintColor",
                          "listToggleThumbColor"]
        
        tableView.register(UINib(nibName: "RGBTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RGBCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let theme = theme {
            setValuesWithObject(object: theme)
        }
    }
    
    func setValuesWithObject(object: AnyObject) {
        for keyPath in self.valueKeys {
            let value = object.value(forKeyPath: keyPath)
            
            if let value = value {
                setValue(value, forKeyPath: keyPath)
            }
        }
    }

    func savePressed() {
        if let theme = theme {
            for keyPath in self.valueKeys {
                let value = self.value(forKeyPath: keyPath)
                
                if let value = value {
                    theme.setValue(value, forKeyPath: keyPath)
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func resetPressed() {
        setValuesWithObject(object: CCCTheme())
        
        tableView.reloadData()
    }
    
    // MARK: UITableView methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = valueKeys[indexPath.row]
        let value = self.value(forKeyPath: key)
        
        let cell: RGBTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RGBCell") as! RGBTableViewCell
        
        if let color = value as? UIColor {
            cell.setTitle(title: key, target: self, key: key, initialValue: color)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
