# FitSwift App

FitSwift is a comprehensive fitness tracking application that integrates with HealthKit and uses Google's Gemini AI to provide personalized fitness insights and recommendations.

## Features

1. **Activity Tracking Dashboard**
   - Profile banner with customizable user image
   - Activity rings showing progress toward Move, Exercise, and Stand goals
   - Activity cards displaying current metrics with daily targets
   - Recent workout summary with quick access to detailed workout history
   - Manual activity creation and deletion for testing and demonstration
   - Edit mode to manage activities and workouts

2. **AI-Powered Fitness Assistant**
   - Conversational interface to interact with fitness data
   - Visual representations of health data through various chart types
   - Personalized workout recommendations
   - Insights on activity patterns and suggestions for improvements
   - Dynamic responses to changes in fitness data

3. **Detailed Activity Analytics**
   - Visual representations of activity data through interactive charts
   - Historical trends showing progress over time
   - Workout type distribution and frequency analysis
   - Detailed breakdown of individual activities and workouts
   - Interactive chart details with selection capabilities
   - Multiple chart types (bar, line, pie) for different metrics

4. **AI Insights Engine**
   - Personalized observations about activity patterns
   - Achievement recognition and progress celebrations
   - Targeted recommendations based on user behavior
   - Identification of potential areas for improvement
   - Workout-specific insights based on activity type
   - Comparison insights between current and previous workouts

5. **Customizable User Profile**
   - Profile picture upload and management
   - Personal information settings
   - Fitness goal configuration

6. **Workout Management**
   - Add custom workouts with detailed information
   - Select from various workout types with appropriate icons
   - Track duration, calories, and date for each workout
   - Visualize workouts in an organized list
   - Delete workouts when needed

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Google Gemini API Key

### API Key Setup
To use the AI features of FitSwift, you need to set up a Google Gemini API key:

1. Get a Gemini API key from [Google AI Studio](https://ai.google.dev/)
2. Copy the `GenerativeAI-Info-template.plist` file to `GenerativeAI-Info.plist`
3. Replace `YOUR_API_KEY_HERE` with your actual API key

```bash
cp GenerativeAI-Info-template.plist GenerativeAI-Info.plist
```

Then edit the `GenerativeAI-Info.plist` file to add your API key.

> **Note:** The `GenerativeAI-Info.plist` file is included in `.gitignore` to prevent accidental exposure of API keys. Never commit this file to version control.

### Installation
1. Clone the repository
2. Set up the API key as described above
3. Open `FitSwift.xcodeproj` in Xcode
4. Build and run the project

## Testing Features

### Manual Activity Creation
For testing purposes, FitSwift allows you to manually create and delete activities and workouts:

1. **Adding Activities**:
   - Tap the "+" button next to "Today Activity" on the home screen
   - Fill in the activity details, select an icon and color
   - Tap "Add" to create the activity

2. **Adding Workouts**:
   - Tap the "+" button next to "Recent Workouts" on the home screen
   - Select a workout type, enter duration and calories
   - Choose a date and color
   - Tap "Add" to create the workout

3. **Deleting Items**:
   - Tap the "Edit" button on the home screen
   - Tap the red minus button on any activity or workout card
   - Tap "Done" to exit edit mode

These manual creation features allow you to test how the AI insights respond to changes in your fitness data without needing to perform actual workouts.

## Dependencies
- [Google Generative AI Swift SDK](https://github.com/google/generative-ai-swift) - For AI-powered features
- SwiftUI - For the user interface
- HealthKit - For accessing health and fitness data
- Charts - For data visualization

## License
This project is licensed under the MIT License - see the LICENSE file for details.
