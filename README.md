![badge](./ed-badge.png)

<img src="https://img.shields.io/badge/Team-UCD%20Prototyping-blue.svg"/> <img src="https://img.shields.io/badge/License-GNU%20GPLv3-blue.svg"/>

----

# GravatarGet
Getting a gravatar image and profile information from an email address that gets md5 hashed. The Gravatar APIs are not difficult to use by any means, but it introduces the need to md5 hash an email address and use that in the API calls for both avatar image and also the profile data. So this is mainly an excercise in hashing.

The requested avatar image delivers either existing image or a default image (random pattern based upon the email hash). 

I am using .json for the requested and returned profile data. I am handling errors.

Because the root of the profile JSON is an array with a single item, it made parsing a little different. Using Codable structs to handle that which makes parsing so much easier than before.

There is rudimentary support for email address validation as one types. You can always kick off a search no matter what the text input field contains. Errors are handled in the user interface.

----

![app](./app.png)

----

### email address validation.

```swift
func isValidEmail(testStr: String) -> Bool {
    let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
    let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}
```

### Hashing.

```swift
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

//Stuff...

func MD5(string: String) -> Data {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: length)
        
    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, 
               let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)
                CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }
            return 0
        }
    }
    return digestData
}

// Use (produce md5 hash from a string). 
let md5Data = MD5(string: someString)
let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
```
