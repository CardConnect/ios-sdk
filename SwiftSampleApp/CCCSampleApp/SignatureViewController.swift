//
//  SignatureViewController.swift
//  CCCSampleApp
//

import UIKit
import CardConnectConsumerSDK

class SignatureViewController: UIViewController {

    @IBOutlet weak var tempDrawImage: UIImageView!
    var lastPoint: CGPoint!
    var touchMoved: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMoved = false
        let touch: UITouch? = touches.first;
        
        if let touch = touch {
            lastPoint = touch.location(in: tempDrawImage)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMoved = true
        let touch: UITouch? = touches.first
        
        if let touch = touch {
            let currentPoint: CGPoint = touch.location(in: tempDrawImage)
            
            let size = tempDrawImage.frame.size
            UIGraphicsBeginImageContext(size)
            tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
            UIGraphicsGetCurrentContext()?.setLineCap(.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(2)
            UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.black.cgColor)
            UIGraphicsGetCurrentContext()?.setBlendMode(.normal)
            
            UIGraphicsGetCurrentContext()?.strokePath()
            tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            tempDrawImage.alpha = 1
            UIGraphicsEndImageContext()
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchMoved {
            let size = tempDrawImage.frame.size
            UIGraphicsBeginImageContext(size)
            tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            UIGraphicsGetCurrentContext()?.setLineCap(.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(2)
            UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.black.cgColor)
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.strokePath()
            UIGraphicsGetCurrentContext()?.flush()
            
            tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }

    @IBAction func clear(_ sender: Any) {
        tempDrawImage.image = nil;
    }
    
    @IBAction func test(_ sender: Any) {
        let original = rotateImage(tempDrawImage.image)
        let compressedImage = CCC_Base64GZippedSignatureForImage(original)
        
        if compressedImage == nil {
            let alert = UIAlertController(title: "Error",
                                          message: "Couldn't compress image.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let unconvertedImage = CCC_ImageFromBase64GZippedString(compressedImage)
        
        if unconvertedImage == nil {
            let alert = UIAlertController(title: "Error",
                                          message: "Couldn't uncompress image.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            present(alert, animated: true, completion: nil)
            return
        } else {
            let alert = UIAlertController(title: "Success", message: "", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            okButton.setValue(shrinkImage(unconvertedImage, size: CGSize(width: 100, height: 50))?.withRenderingMode(.alwaysOriginal), forKey: "image")
            alert.addAction(okButton)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func rotateImage(_ image: UIImage?) -> UIImage? {
        if let image = image {
            let size = image.size
            
            if let cgImage = image.cgImage {
                UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
                UIImage(cgImage: cgImage, scale: 1.0, orientation: .left).draw(in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return newImage
            }
        }
        
        return image
    }
    
    func shrinkImage(_ image: UIImage?, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
