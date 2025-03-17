# SavingsJarMacApp

A modern macOS app to track and manage your savings goals with a beautiful, intuitive interface.

## Features

- **Multiple Savings Goals**: Create and manage different savings jars for various goals
- **Visual Progress Tracking**: See your progress with smooth progress bars
- **Custom Categorization**: Choose from different colors and icons for each savings jar
- **Detailed Analytics**: View total savings, progress percentages, and completion status
- **Transaction Management**: Add or withdraw money from your savings jars
- **Persistent Storage**: Your savings data is automatically saved between sessions

## Installation

1. Download the latest release from the [Releases](https://github.com/yourusername/SavingsJar/releases) page
2. Drag the Savings Jar app to your Applications folder
3. Launch the app from your Applications folder or Launchpad

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

## Future Plans

- iCloud sync support for using across multiple devices
- Budget planning features
- Reminder notifications for regular savings contributions
- Exporting data to CSV for analysis
- Importing data from financial apps

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
- Built with SwiftUI
- Inspired by personal finance best practices

---

Note: Remember to replace "yourusername" with your actual GitHub username and add actual screenshots of your app to the project. You might need to create a "screenshots" folder in your repository and add the images there.
