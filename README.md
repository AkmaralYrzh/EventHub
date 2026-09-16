# EventHub

Дипломный проект курса iOS-разработки (КОДЕКО, 9 поток, 2026).
Приложение-афиша: пользователи ищут мероприятия в своём городе и сохраняют их в избранное, организаторы публикуют и ведут свои события.

## Функциональность

- Онбординг при первом запуске
- Регистрация и вход по email / паролю (Firebase Auth)
- Две роли — **пользователь** и **организатор** — с разными главными экранами
- Выбор города, лента событий с фильтром по категориям
- Экран деталей события
- Создание события организатором (Firestore)
- Избранное, привязанное к профилю пользователя
- Профиль и настройки: тёмная тема, выбор языка
- Локализация: русский, казахский, английский

## Технологии

| | |
|---|---|
| Язык | Swift 5 |
| UI | UIKit, вёрстка кодом (Auto Layout / NSLayoutConstraint), UICollectionView |
| Архитектура | MVVM + Coordinator |
| Реактивность | Combine (`AnyPublisher`, `Future`, `sink`) |
| Backend | Firebase Auth, Cloud Firestore |
| Зависимости | Swift Package Manager |
| Хранение настроек | UserDefaults (расширение с типизированными ключами) |

## Структура проекта

```
App/            AppDelegate, SceneDelegate
Coordinator/    AppCoordinator — маршрутизация: онбординг → логин → главная по роли
Modules/        Экраны: Auth, Onboarding, CitySelection, Home (User / Organizer),
                EventDetails, CreateEvent, Favorites, Profile, Settings, SignUp
                Каждый модуль = View + ViewController + ViewModel
Service/        AuthService, EventService — работа с Firebase через Combine
UiComponents/   EventCardCell, UiCategoryChip, UiCityCard, цвета и стили
Localization/   ru / kk / en
Extensions/     UserDefaults+Extensions
```

## Запуск

1. Клонировать репозиторий и открыть `EventHub.xcodeproj` в Xcode 15+.
2. Создать проект в [Firebase Console](https://console.firebase.google.com), включить Authentication (Email/Password) и Cloud Firestore.
3. Скачать `GoogleService-Info.plist` и положить его в папку `Coordinator/` (файл не хранится в репозитории).
4. Дождаться загрузки Swift-пакета `firebase-ios-sdk` и запустить на симуляторе.

## Автор

Акмарал Ержан — [dakaass@icloud.com](mailto:dakaass@icloud.com)
