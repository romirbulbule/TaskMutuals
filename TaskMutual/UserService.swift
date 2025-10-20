import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {
    static let shared = UserService()

    private init() {}

    func fetchAndStoreUsernameForCurrentUser(completion: ((String?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(nil)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { doc, error in
            let username = doc?.data()?["username"] as? String
            UserDefaults.standard.set(username, forKey: "username")
            completion?(username)
        }
    }
}
