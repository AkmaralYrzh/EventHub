import Foundation
import FirebaseAuth

protocol AuthUser:AnyObject {
    var uid:String {get}
    var email:String? {get}
    var phoneNumber:String? {get}
    var displayName:String? {get}
    var isAnonymous:Bool {get}
    var isEmailVerified:Bool {get}
    var providerData: [ UserInfo] {get}
    
}
extension User:AuthUser {}
