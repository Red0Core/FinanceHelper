# Finance Helper - Your Personal Finance Manager

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev) [![Sqflite](https://img.shields.io/badge/Sqflite-00796b?style=for-the-badge&logo=sqlite&logoColor=white)](https://pub.dev/packages/sqflite) [![GoRouter](https://img.shields.io/badge/GoRouter-0288d1?style=for-the-badge&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAG/SURBVHgB1ZTdS8NAFMW390y5s4uX0o+qA/QJ/gAL0C6hD6A4j4vEBAX4AR8ggp+AScAgJtO3mZ3dmV+p/7D2J/e9z/Lz455j+0q53gH4i9A4gO4J8C/AV4gY3wD3A7iP4Z+A7iM5wE4N/gLgH8z+G+APeB7D4H8z+P/Q+A/gXwH4z9n/t84C+C/AB89wR2s8K7JzFkCgB/A78v5D9xX4hOACgO4d84D8G8P8K804N8D/Afy36Q4u+gZg8N8D/hD132L+I0f854M+BfD4g78v8H+X/E8H/J4K+D/hPxX4P/T+Q4P+xXwH5/8z/E/E/n+N4L+V/F/wP5/xX2v8D8D/D/w4B/D/E79X8H+r/xPh/wP5HwP8uA/yX8E/w58D+e8B/j/V/D/wJ8H8X8T99/B8D/wL8j/H/l/AP4x+j/T9sE+E/AH4C+H/F/U37T+1+O7oAAAAAElFTkSuQmCC&logoColor=white)](https://pub.dev/packages/go_router)

Finance Helper is a Flutter-based mobile application designed to help you manage your personal finances effectively. It allows you to track your transactions, manage your cards, set financial goals, and monitor your cashback opportunities.

## Features

*   **Transaction Tracking:**
    *   Record your income and expenses.
    *   Categorize your transactions.
    *   View a history of all transactions, sorted by date.
    *   Filter transactions by card and type (income/expense).
    *   Edit and delete transactions.
*   **Card Management:**
    *   Add, edit, and delete cards.
    *   View the balance of each card.
    * Show all of your cards.
*   **Cashback Tracking:**
    *   Add cashback offers for specific categories.
    *   Assign cashback offers to different cards.
    * Track cashback with list of all saved cashback.
    * Check best cashback for current transaction.
*   **Financial Goals:**
    * Add financial goals.
    * Set target amounts and deadlines.
*   **Subscriptions:**
    * Add subscription.
    * Set renewal date.
*   **User-Friendly Interface:**
    *   Clean and intuitive design.
    *   Easy navigation.
* **Database**:
   * All data is saved to local database.

## Technologies Used

*   **Flutter:** The core framework for building the mobile app.
*   **Dart:** The programming language used for Flutter.
*   **sqflite:** Local database for storing transactions, cards, cashbacks, subscriptions and financial goals data.
*   **GoRouter:** For declarative routing and navigation.
* **Intl**: For localization and date formating.

## Getting Started

1.  **Prerequisites:**
    *   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
    *   Android Studio or VS Code with Flutter and Dart plugins installed.
    *   An Android or iOS emulator, or a physical device.

2.  **Installation:**
    *   Clone the repository:
    *   Get the dependencies:
        ```bash
        flutter pub get
        ```

3.  **Running the App:**
    *   Connect your device or start the emulator.
    *   Run the app:
        ```bash
        flutter run
        ```

## Contributing

Contributions are welcome! If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcome.

## License

[MIT](https://opensource.org/license/mit/)