//
//  ViewController.swift
//  Promptpay-QR
//
//  Created by Issara Boonyamoon on 9/18/17.
//  Copyright © 2017 Issara Boonyamoon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        self.reloadQRCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadQRCode() {
        let moneyText = self.moneyTextField.text ?? ""
        var accountId = self.idTextField.text ?? ""
        
        if (accountId.characters.count == 15) {
            // truemoney e-wallet
            accountId = "0315" + accountId;
        } else if(accountId.characters.count == 13) {
            // card-id
            accountId = "0213" + accountId;
        } else if(accountId.characters.count == 10) {
            // tel-no
            let index = accountId.index(accountId.startIndex, offsetBy: 1)
            accountId = "01130066" + accountId.substring(from: index)
        }
        
        let amount = "54" + String(format: "%02d", (moneyText.characters.count)) + moneyText
        let code = "00020101021129370016A000000677010111" + accountId + "5303764" + amount + "5802TH6304"
        let chsum = String(format: "%04X", crc16(code)!).uppercased()
        
        self.QRCodeImageView.image = generateQRCode(from: code + chsum,
                                                    width: QRCodeImageView.frame.size.width,
                                                    height: QRCodeImageView.frame.size.height)
    }
    
    @IBAction func textFieldDidEditingChanged(_ textField: UITextField) {
        reloadQRCode()
    }
    
    // MARK: - Utilities
    func generateQRCode(from string: String, width: CGFloat, height: CGFloat) -> UIImage? {
        let data = string.data(using: .ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let scaleX = width / (filter.outputImage?.extent.size.width)!
            let scaleY = height / (filter.outputImage?.extent.size.height)!
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    func crc16(_ data: String) -> UInt32? {
        var crc: UInt32 = 0xFFFF;
        for c in data.characters {
            let s = String(c).unicodeScalars
            var x = ((crc >> 8) ^ UInt32(s[s.startIndex].value)) & 0xFF
            x ^= x >> 4
            crc = ((crc << 8) ^ (x << 12) ^ (x << 5) ^ x) & 0xFFFF
        }
        return crc
    }
}

