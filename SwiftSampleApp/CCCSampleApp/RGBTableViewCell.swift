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

class RGBTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var targetAny: AnyObject?
    var key: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.gray.cgColor
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let newColor: UIColor = colorFromSliders()
        
        UIView.animate(withDuration: 0.1) { 
            self.colorView.backgroundColor = newColor
        }
        
        if let key = key, let targetAny = targetAny {
            targetAny.setValue(newColor, forKey: key)
        }
    }
    
    func colorFromSliders() -> UIColor {
        return UIColor.init(colorLiteralRed: redSlider.value,
                            green: greenSlider.value,
                            blue: blueSlider.value,
                            alpha: 1.0)
    }
    
    func setTitle(title: String, target: AnyObject, key: String, initialValue: UIColor?) {
        self.titleLabel.text = title
        self.targetAny = target
        self.key = key
        
        if let color = initialValue {
            let compCount: Int = color.cgColor.numberOfComponents
            let colors: [CGFloat]? = color.cgColor.components
            
            if compCount == 4 {
                if let colors = colors {
                    redSlider.value = Float(colors[0])
                    greenSlider.value = Float(colors[1])
                    blueSlider.value = Float(colors[2])
                }
            }
            else
            {
                if let colors = colors {
                    let color: Float = Float(colors[0])
                    redSlider.value = color
                    greenSlider.value = color
                    blueSlider.value = color
                }
            }
            
            colorView.backgroundColor = colorFromSliders()
        }
    }
    
}
