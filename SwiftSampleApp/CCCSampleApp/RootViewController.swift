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

class RootViewController: UIViewController, CCCPaymentControllerDelegate {

    let apiBridge = BridgingAPI.instance
    var paymentController: CCCPaymentController!
    var theme: CCCTheme!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theme = CCCTheme()
        theme.disclaimerText = "Put some explainatory text here. Tell the user about whatever legal stuff you need to."
        paymentController = CCCPaymentController(rootView: self, apiBridge: apiBridge, delegate: self, theme: theme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination.isKind(of: ThemingTableViewController.self)) {
            (segue.destination as! ThemingTableViewController).theme = theme
        }
    }
    
    // MARK: IBAction methods
    
    @IBAction func integratedFlowPressed(_ sender: Any) {
        let applePayRequest = CCCPaymentRequest()
        applePayRequest.applePayMerchantID = ""
        applePayRequest.total = NSDecimalNumber(string: "120.00")
        
        paymentController.paymentRequest = applePayRequest
        
        paymentController.presentPaymentView()
    }
    
    @IBAction func stackIntegratedFlowPressed(_ sender: Any) {
        paymentController.pushPaymentView()
    }
    
    // MARK: CCCPaymentControllerDelegate methods
    
    func paymentController(_ controller: CCCPaymentController, finishedWith account: CCCAccount) {
        
    }
    
    func didCancel(_ controller: CCCPaymentController) {
        
    }
    
    func paymentController(_ controller: CCCPaymentController, finishedApplePayWithResult result: Bool) {
        
    }

}
