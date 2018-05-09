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

class CardEntryViewController: UIViewController, CCCFormatterDelegateExtension, CCCSwiperDelegate {

    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var CVVTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var swiperStatusLabel: UILabel!
    
    @IBOutlet weak var generateTokenBarButton: UIBarButtonItem!
    
    @IBOutlet weak var maskFormatSegmentedControl: UISegmentedControl!
    @IBOutlet weak var maskCharacterSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var cardFormatterDelegate: CCCCardFormatterDelegate!
    @IBOutlet weak var expirationFormatterDelegate: CCCExpirationDateFormatterDelegate!
    @IBOutlet weak var cvvFormatterDelegate: CCCCVVFormatterDelegate!
    
    var swiper: CCCSwiperController?
    var card: CCCCardInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        card = CCCCardInfo()
        
        cardNumberTextField.rightViewMode = .always
        expirationDateTextField.rightViewMode = .always
        CVVTextField.rightViewMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        swiper = CCCSwiperController(delegate: self, loggingEnabled: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        swiper = nil
    }
    
    // MARK: Internal Methods
    
    func i_startActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func i_stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func i_updateCreateButton() {
        self.generateTokenBarButton.isEnabled = self.cardFormatterDelegate.isValidCard &&
                                                self.expirationFormatterDelegate.isValidExpirationDate &&
                                                self.cvvFormatterDelegate.isValidCVV()
    }
    
    // MARK: Action Methods

    @IBAction func generateTokenPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        i_startActivityIndicator()
        
        CCCAPI.instance().generateAccount(forCard: card) { (account: CCCAccount?, error: Error?) in
            self.i_stopActivityIndicator()
            
            self.cardFormatterDelegate.clearTextField()
            self.expirationFormatterDelegate.clearTextField()
            self.cvvFormatterDelegate.clearTextField()
            self.postalCodeTextField.text = ""
            self.card = CCCCardInfo()
            
            self.i_updateCreateButton()
            
            if let account = account {
                let alert = UIAlertController(title: "Token Generated", message: account.token, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender == self.maskFormatSegmentedControl {
            switch sender.selectedSegmentIndex {
            case 0:
                self.cardFormatterDelegate.maskFormat = .maskWithLastFour
                break
            case 1:
                self.cardFormatterDelegate.maskFormat = .lastFour
                break
            case 2:
                self.cardFormatterDelegate.maskFormat = .firstAndLastFour
                break
            default:
                break
            }
        } else {
            switch sender.selectedSegmentIndex {
            case 0:
                let charString = "*"
                
                self.cardFormatterDelegate.maskCharacter = charString.utf16.first!
                self.cvvFormatterDelegate.maskCharacter = charString.utf16.first!
                
                break
            case 1:
                let charString = "&"
                
                self.cardFormatterDelegate.maskCharacter = charString.utf16.first!
                self.cvvFormatterDelegate.maskCharacter = charString.utf16.first!
                break
            case 2:
                let charString = "-"
                
                self.cardFormatterDelegate.maskCharacter = charString.utf16.first!
                self.cvvFormatterDelegate.maskCharacter = charString.utf16.first!
                break
            default:
                break
            }
        }
    }
    
    // MARK: CCCFormatterDelegateExtension Methods
    
    func didChangeCharactersInRange(forFormatter formatter: CCCTextFieldDelegateProxy!) {
        if formatter == self.cardFormatterDelegate {
            if let cardNumberText = self.cardNumberTextField.text,
                (cardNumberText.characters.count > 0 &&
                !self.cardFormatterDelegate.isValidCard) {
                let xLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                xLabel.text = "X"
                xLabel.textColor = UIColor.red
                xLabel.font = UIFont.boldSystemFont(ofSize: 20)
                xLabel.textAlignment = .center
                
                self.cardNumberTextField.rightView = xLabel
            } else {
                self.cardNumberTextField.rightView = nil
                self.cardFormatterDelegate.setCardNumberOn(card)
            }
        } else if formatter == self.expirationFormatterDelegate {
            if let expirationDateText = self.expirationDateTextField.text,
                (expirationDateText.characters.count > 0 &&
                !self.expirationFormatterDelegate.isValidExpirationDate) {
                let xLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                xLabel.text = "X"
                xLabel.textColor = UIColor.red
                xLabel.font = UIFont.boldSystemFont(ofSize: 20)
                xLabel.textAlignment = .center
                
                self.expirationDateTextField.rightView = xLabel
            } else {
                self.expirationDateTextField.rightView = nil
                self.expirationFormatterDelegate.setExpirationDateOn(card)
            }
        } else if formatter == self.cvvFormatterDelegate {
            if let cvvText = self.CVVTextField.text,
                (cvvText.characters.count > 0 &&
                !self.cvvFormatterDelegate.isValidCVV()) {
                let xLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                xLabel.text = "X"
                xLabel.textColor = UIColor.red
                xLabel.font = UIFont.boldSystemFont(ofSize: 20)
                xLabel.textAlignment = .center
                
                self.CVVTextField.rightView = xLabel
            } else {
                self.CVVTextField.rightView = nil
                self.cvvFormatterDelegate.setCVVOn(card)
            }
        }
        
        i_updateCreateButton()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.cardNumberTextField {
            card.cardNumber = nil
        } else if textField == self.expirationDateTextField {
            card.expirationDate = nil
        } else if textField == self.CVVTextField {
            card.cvv = nil
        }
        
        i_updateCreateButton()
        
        return true
    }
    
    // MARK: SwiperDelegate Methods
    
    func swiper(_ swiper: CCCSwiper!, connectionStateHasChanged state: CCCSwiperConnectionState) {
        switch state {
        case .connected:
            print("Did connect swiper")
            self.swiperStatusLabel.text = "Connected"
        case .disconnected:
            print("Did disconnect swiper")
            self.swiperStatusLabel.text = "Disconnected"
        case.connecting:
            print("Swiper is connecting")
            self.swiperStatusLabel.text = "Connecting"
        }
    }
    
    func swiperDidStartMSR(_ swiper: CCCSwiper!)
    {
        print("MSR Started")
        self.view.endEditing(true)
        i_startActivityIndicator()
    }
    
    func swiper(_ swiper: CCCSwiper!, didGenerateTokenWith account: CCCAccount!, completion: (() -> Void)!)
    {
        i_stopActivityIndicator()
        
        if let account = account
        {
            let alert = UIAlertController(title: "Token Generated", message: account.token, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: { (_) in
                completion()
            })
        }
        else
        {
            completion()
        }
    }
    
    func swiper(_ swiper: CCCSwiper!, didFailWithError error: Error!, completion: (() -> Void)!)
    {
        i_stopActivityIndicator()
        
        let controller = UIAlertController(title: "", message: String.init(format: "An error occured: \n%@", error.localizedDescription), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
            completion()
        }))
        present(controller, animated: true, completion: nil)
    }
    
}
