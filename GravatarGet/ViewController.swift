//
//  ViewController.swift
//  GravatarGet
//
//  Created by Eric Dolecki on 7/11/19.
//  Copyright © 2019 Eric Dolecki. All rights reserved.
//

import UIKit
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG


struct Root: Codable {
    let entry: [Entry]
}

struct Entry: Codable {
    let id, hash, requestHash: String
    let profileURL: String
    let preferredUsername: String
    let thumbnailURL: String
    let photos: [Photo]
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case id, hash, requestHash
        case profileURL = "profileUrl"
        case preferredUsername
        case thumbnailURL = "thumbnailUrl"
        case photos, displayName
    }
}

struct Photo: Codable {
    let value: String
    let type: String
}

/*
    email addresses are case-sensitive FYI.
 */
class ViewController: UIViewController, UITextFieldDelegate {

    var imageView: UIImageView!
    var textInput: UITextField!
    var debugLabel: UILabel!
    var errorLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 250)
        
        textInput = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 50, height: 40))
        textInput.center = CGPoint(x: self.view.frame.width / 2, y: imageView.center.y + 130)
        textInput.keyboardType = .emailAddress
        textInput.backgroundColor = UIColor.white
        textInput.placeholder = "email address"
        textInput.text = "edolecki@gmail.com"
        textInput.layer.shadowColor = UIColor.black.cgColor
        textInput.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        textInput.layer.shadowRadius = 7.0
        textInput.layer.shadowOpacity = 0.15
        textInput.clearButtonMode = .whileEditing
        textInput.autocapitalizationType = .none
        textInput.spellCheckingType = .no
        textInput.layer.cornerRadius = 8.0
        textInput.returnKeyType = .search
        textInput.delegate = self
        textInput.layer.borderColor = UIColor.blue.cgColor
        textInput.layer.borderWidth = 1.5
        textInput.becomeFirstResponder()
        textInput.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        textInput.leftViewMode = UITextField.ViewMode.always
        textInput.leftView = spacerView
        
        debugLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 50, height: 80))
        debugLabel.center = CGPoint(x: textInput.center.x, y: textInput.center.y + 60)
        debugLabel.font = UIFont.systemFont(ofSize: 13.0)
        debugLabel.textColor = UIColor.darkGray
        debugLabel.textAlignment = .center
        debugLabel.numberOfLines = 3
        
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 50, height: 50))
        errorLabel.center = CGPoint(x: debugLabel.center.x, y: debugLabel.center.y + 50)
        errorLabel.font = UIFont.systemFont(ofSize: 13.0)
        errorLabel.textColor = UIColor.red
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 3
        
        self.view.addSubview(imageView)
        self.view.addSubview(textInput)
        self.view.addSubview(debugLabel)
        self.view.addSubview(errorLabel)
        
        attemptToLoadGravatar(emailString: "edolecki@gmail.com")
    }
    
    // MARK: - Fetch Gravatar Information
    
    func attemptToLoadGravatar(emailString: String)
    {
        let md5Data = MD5(string: emailString)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        let imageString = "http://gravatar.com/avatar/\(md5Hex).jpg?size=200&d=identicon"
        imageView.downloaded(from: imageString)
        attemptToLoadProfile(hash: md5Hex)
    }
    
    func attemptToLoadProfile(hash: String)
    {
        let url = "https://www.gravatar.com/\(hash).json"
        let fileURL = URL(string: url)
        do {
            let contents = try String(contentsOf: fileURL!)
            let data = contents.data(using: String.Encoding.utf8)
            let decoder = JSONDecoder()
            let root = try decoder.decode(Root.self, from: data!)
            
            //print(root)
            
            let base = root.entry[0]
            let displayName = base.displayName
            let hash = base.hash
            let id = base.id

            //print(base.photos[0].type, base.photos[0].value)
            
            debugLabel.text = "Display: \(displayName)\nmd5: \(hash), ID: \(id)"
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
           
        } catch {
            print("Error. \(error.localizedDescription)")
            errorLabel.text = "\(error.localizedDescription)"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            UIView.animate(withDuration: 0.6) {
                self.errorLabel.alpha = 1.0
            }
            debugLabel.text = ""
        }
    }
    
    // MARK: - Dismiss the keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return false
        }
        errorLabel.alpha = 0
        attemptToLoadGravatar(emailString: text)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.35) {
            self.textInput.layer.shadowOpacity = 0.05
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.35) {
            self.textInput.layer.shadowOpacity = 0.15
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textInput.layer.borderColor = UIColor.red.cgColor
        return true
    }

    // MARK: - Validate email
    
    @objc func textFieldDidChange(sender: UITextField) {
        let text = sender.text
        if !sender.hasText {
            print("no text to email validate.")
            return
        }
        let isValid = isValidEmail(testStr: text!)
        print(text!, isValid)
        if isValid {
            textInput.layer.borderColor = UIColor.blue.cgColor
        } else {
            textInput.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // MARK: - Hashing
    
    func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
