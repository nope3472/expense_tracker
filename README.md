# Expense Tracker

Expense Tracker is a Flutter-based mobile application designed to help users track their income and expenses. The app integrates with Firebase Firestore for real-time data storage, provides financial insights with dynamic charts, and allows users to manage custom categories with personalized icons.

## Features

- **Expense & Income Tracking**  
  Record and manage daily expenses and income easily.

- **Category Management**  
  - Predefined default categories (e.g., Food, Leisure, Work, Travel).  
  - Create, edit, and delete custom categories with custom icons from your assets.

- **Financial Overview Dashboard**  
  - View total income, total expenses, and net balance for the current month.  
  - Visualize spending per category using a horizontal scrollable bar graph.

- **Offline Persistence**  
  Firestore caches your data locally, ensuring your information is available even without an internet connection.

- **Real-Time Updates**  
  Changes synchronize automatically with Firebase for an always up-to-date view of your finances.

## Tech Stack

- **Flutter** – Cross-platform mobile development framework.
- **Firebase Firestore** – Cloud-based real-time database.
- **fl_chart** – Package for interactive and visually appealing charts.
- **Dart** – Programming language used with Flutter.
- 
## Screenshots
<img src="https://github.com/user-attachments/assets/ac8c6b39-619d-47d7-9c8f-a9c871675d63" width="200" />
<img src="https://github.com/user-attachments/assets/bbcaafd3-ccc9-4504-8e4c-ab2046f021e5" width="200" />
<img src="https://github.com/user-attachments/assets/5b8dafbb-7a88-43ef-90f8-acbef6c7f15a" width="200" />
<img src="https://github.com/user-attachments/assets/b7cb5a5c-00e9-40b3-bae1-1dc266d191af" width="200" />



## Technologies Used

- **Flutter**: Frontend framework for building a cross-platform mobile application.
- **Firebase Firestore**: Cloud-based NoSQL database used to store and retrieve expenses in real-time.
- **Charts in Flutter**: Visualize expenses using pie charts and bar charts.
- **State Management**: Flutter's built-in `setState` and stateful widgets for managing app state.
- **Material Design**: Uses Flutter's material widgets for UI components like buttons, modals, and snackbars.
  
## Installation & Setup

Follow these instructions to set up and run the project locally.

### Prerequisites
- **Flutter SDK** installed on your machine. You can install Flutter by following the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
- **Firebase account** for Firestore database integration.
- **Android Studio** or **VS Code** with Flutter extension for IDE.

### Clone the Repository

```bash
git clone https://github.com/your-username/expense-tracker-flutter.git
cd expense-tracker-flutter
