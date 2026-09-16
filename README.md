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
- Запись на мероприятие: «Записаться / Отменить запись», счётчик участников, мои записи в профиле
- Профиль: редактирование имени, смена пароля, удаление аккаунта
- Настройки: тёмная тема, язык (ru / kk / en), уведомления, поддержка
- Локализация: русский, казахский, английский
- Состояния списков: загрузка, пустой экран, ошибка с повтором

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
| Тесты | XCTest — 19 unit-тестов (модели, фильтрация, валидация даты, состояния) |

## Структура проекта

```
App/            AppDelegate, SceneDelegate
Coordinator/    AppCoordinator — маршрутизация: онбординг → логин → главная по роли
Modules/        Экраны: Auth, Onboarding, CitySelection, Home (User / Organizer),
                EventDetails, CreateEvent, Favorites, Profile, Settings, SignUp
                Каждый модуль = View + ViewController + ViewModel
Service/        AuthService, EventService — работа с Firebase через Combine
UiComponents/   EventCardCell, UiCategoryChip, UiCityCard, UiStateView, палитра UiColor
Localization/   ru / kk / en
Extensions/     UserDefaults, Date, UIViewController+Keyboard
EventHubTests/  unit-тесты
```

## Тесты

```
xcodebuild test -scheme EventHub -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## После защиты

Проект защищён 1 сентября 2026 (80 баллов). По замечаниям комиссии доработано:

- валидация даты при создании мероприятия (`minimumDate`, дата участвует в готовности формы)
- запись на мероприятие (`participantIds`, `arrayUnion` / `arrayRemove`)
- все строки настроек функциональны, добавлен экран редактирования профиля
- типизированные ошибки авторизации (`AuthError`) вместо одного текста
- индикатор загрузки, пустое состояние и ошибка с повтором на всех списках (`UiStateView`)
- палитра цветов только в `UiColor.swift`, закрытие клавиатуры на формах
- фильтрация ленты перенесена из ViewController в ViewModel
- добавлен таргет `EventHubTests`

> Firestore: для записи на мероприятие правила безопасности должны разрешать посетителям
> обновлять поле `participantIds` в документах `events`.

## Запуск

1. Клонировать репозиторий и открыть `EventHub.xcodeproj` в Xcode 15+.
2. Создать проект в [Firebase Console](https://console.firebase.google.com), включить Authentication (Email/Password) и Cloud Firestore.
3. Скачать `GoogleService-Info.plist` и положить его в папку `Coordinator/` (файл не хранится в репозитории).
4. Дождаться загрузки Swift-пакета `firebase-ios-sdk` и запустить на симуляторе.

## Автор

Акмарал Ержан — [dakaass@icloud.com](mailto:dakaass@icloud.com)
