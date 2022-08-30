import UIKit

@objc extension UIColor {
    public convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((rgb & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((rgb & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( rgb & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
