# Mocklet

A Flutter-based cryptocurrency tracking and wallet application that provides users with real-time crypto data, portfolio management, and more.

## Features

- **User Authentication**: Secure login and signup with Firebase Auth and Google Sign-In
- **Cryptocurrency Tracking**: Real-time data from CoinGecko API
- **Portfolio Management**: Track your crypto holdings and wallet
- **Search Functionality**: Easily search for cryptocurrencies
- **Multi-language Support**: Localization with easy_localization
- **Offline Storage**: Local data persistence with Hive
- **Charts and Analytics**: Visualize crypto trends with Syncfusion charts

## Screenshots

_(Add screenshots here if available)_

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio or Xcode for mobile development

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/ArdaKoksall/mocklet_source.git
   cd mocklet_source
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

### Running the App

For Android:

```bash
flutter run
```

For iOS:

```bash
flutter run --flavor development
```

## Project Structure

```
lib/
├── api/           # API services
├── app/           # Core app logic and services
├── models/        # Data models
├── screens/       # UI screens
│   ├── first/     # Authentication screens
│   └── second/    # Main app screens
└── main.dart      # App entry point
```

## Dependencies

Key dependencies include:

- Firebase for authentication and analytics
- Riverpod for state management
- Dio for HTTP requests
- Hive for local storage
- Syncfusion for charts
- Video player for tutorials

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- CoinGecko API for cryptocurrency data
- Flutter community for amazing documentation and packages
