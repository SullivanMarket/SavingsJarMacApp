# Savings Jar Mac App
A modern macOS app to track and manage your savings goals with a beautiful, intuitive interface.

## Features
- **Multiple Savings Goals**: Create and manage different savings jars for various goals
- **Visual Progress Tracking**: See your progress with smooth progress bars
- **Custom Categorization**: Choose from different colors and icons for each savings jar
- **Detailed Analytics**: View total savings, progress percentages, and completion status
- **Transaction Management**: Add or withdraw money from your savings jars
- **Persistent Storage**: Your savings data is automatically saved between sessions
- **macOS Widgets**: Keep track of your savings goals right from your desktop with custom widgets

## Installation
1. Download the latest release from the [Releases](https://github.com/ssullivan06902/SavingsJarMacApp/tree/main/Savings%20Jar/Releases) page
2. Drag the Savings Jar app to your Applications folder
3. Launch the app from your Applications folder or Launchpad
4. To add widgets:
   - Right-click on your desktop and select "Edit Widgets"
   - Search for "Savings Jar"
   - Drag and drop your preferred widget to your desktop

## Development
### Requirements
- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

### Building from Source
1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/SavingsJar.git
   cd SavingsJar
   ```
2. Open the project in Xcode
   ```bash
   open "Savings Jar.xcodeproj"
   ```
3. Build and run the project in Xcode

## How It Works
Savings Jar uses SwiftUI for its interface and stores data using UserDefaults for persistence. The app follows the MVVM (Model-View-ViewModel) architecture pattern for clean separation of concerns:
- **Models**: Define the data structure for savings jars
- **ViewModels**: Handle business logic and data operations
- **Views**: Present the interface and interact with the user
- **Widgets**: Use WidgetKit to display your savings data right on your desktop

## Widgets
Savings Jar includes customizable widgets for your macOS desktop:
- **Progress Widget**: View the progress of your selected savings jar
- **Summary Widget**: See an overview of all your savings goals
- **Quick Add Widget**: Quickly add contributions to your savings goals

Widgets update automatically when you make changes in the main app.

## Future Plans
- iCloud sync support for using across multiple devices
- Budget planning features
- Reminder notifications for regular savings contributions
- Exporting data to CSV for analysis
- Importing data from financial apps
- Additional widget sizes and customization options

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- Icons from SF Symbols
- Built with SwiftUI and WidgetKit
- Inspired by personal finance best practices
---
