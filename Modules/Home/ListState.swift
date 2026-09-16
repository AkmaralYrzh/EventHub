import Foundation

/// Состояние любого экрана-списка. ViewModel публикует его,
/// а UiStateView показывает индикатор, пустой экран или ошибку.
enum ListState: Equatable {
    case loading
    case loaded
    case empty(message: String)
    case error(message: String)

    /// Считается из результата загрузки: пустой список → empty, иначе loaded.
    static func from<T>(_ items: [T], emptyMessage: String) -> ListState {
        items.isEmpty ? .empty(message: emptyMessage) : .loaded
    }
}
