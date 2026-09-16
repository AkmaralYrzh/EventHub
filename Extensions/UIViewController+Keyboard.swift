import UIKit

extension UIViewController {

    /// Тап по свободному месту экрана закрывает клавиатуру.
    /// `cancelsTouchesInView = false` — чтобы кнопки и ячейки продолжали получать нажатия.
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
