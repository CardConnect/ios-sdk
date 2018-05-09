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

class BridgingAPI: NSObject, CCCAPIBridgeProtocol {

    static let instance: BridgingAPI = BridgingAPI()
    
    var accounts: NSMutableArray!
    
    override init() {
        super.init()
        
        accounts = NSMutableArray()
        setupAccounts()
    }
    
    func ccc_getAccounts(_ completion: (([CCCAccount]?, Error?) -> Void)!) {
        completion(accounts as? [CCCAccount], nil)
    }
    
    func ccc_saveAccount(toCustomer account: CCCAccount!, completion: ((CCCAccount?, Error?) -> Void)!) {
        account.accountID = String(format: "%lu", accounts.count)
        accounts.add(account)
        completion(account, nil)
    }
    
    func ccc_deleteCustomerAccount(_ accountID: String!, completion: ((Bool, Error?) -> Void)!) {
        if let accountID = Int(accountID) {
            accounts.removeObject(at: Int(accountID))
            completion(true, nil)
        } else {
            completion(false, nil)
        }
    }
    
    func ccc_update(_ account: CCCAccount!, completion: ((CCCAccount?, Error?) -> Void)!) {
        accounts.replaceObject(at: Int(account.accountID)!, with: account)
        completion(account, nil)
    }
    
    func ccc_authApplePayTransaction(withToken token: String!, completion: ((Bool, Error?) -> Void)!) {
        completion(true, nil)
    }
    
    func setupAccounts() {
        let account = CCCAccount()
        account.accountID = "0"
        account.accountType = CCC_AccountTypeForIssuer(.masterCard)
        account.defaultAccount = true
        account.expirationDate = Date()
        account.name = "Cardholders Name"
        account.token = "4658216846214761"

        accounts.add(account)
        
        let account2 = CCCAccount()
        account2.accountID = "1"
        account2.accountType = CCC_AccountTypeForIssuer(.VISA)
        account2.defaultAccount = false
        account2.expirationDate = Date()
        account2.name = "Cardholders Name"
        account2.token = "4658216846211259"
        
        accounts.add(account2)
        
        let account3 = CCCAccount()
        account3.accountID = "2"
        account3.accountType = CCC_AccountTypeForIssuer(.AMEX)
        account3.defaultAccount = false
        account3.expirationDate = Date()
        account3.name = "Cardholders Name"
        account3.token = "4658216846219876"
        
        accounts.add(account3)
        
        let account4 = CCCAccount()
        account4.accountID = "3"
        account4.accountType = CCC_AccountTypeForIssuer(.VISA)
        account4.defaultAccount = false
        account4.expirationDate = Date()
        account4.name = "Cardholders Name"
        account4.token = "4658216846218273"
        
        accounts.add(account4)
    }
    
}
