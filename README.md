# FitSwift App

FitSwift is a comprehensive fitness tracking application that integrates with HealthKit and uses Google's Gemini AI to provide personalized fitness insights and recommendations.

## Features

1. **Activity Tracking Dashboard**
   - Profile banner with customizable user image
   - Activity rings showing progress toward Move, Exercise, and Stand goals
   - Activity cards displaying current metrics with daily targets
   - Recent workout summary with quick access to detailed workout history

2. **AI-Powered Fitness Assistant**
   - Conversational interface to interact with fitness data
   - Visual representations of health data through various chart types
   - Personalized workout recommendations
   - Insights on activity patterns and suggestions for improvements

3. **Detailed Activity Analytics**
   - Visual representations of activity data through interactive charts
   - Historical trends showing progress over time
   - Workout type distribution and frequency analysis
   - Detailed breakdown of individual activities and workouts

4. **AI Insights Engine**
   - Personalized observations about activity patterns
   - Achievement recognition and progress celebrations
   - Targeted recommendations based on user behavior
   - Identification of potential areas for improvement

5. **Customizable User Profile**
   - Profile picture upload and management
   - Personal information settings
   - Fitness goal configuration

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Google Gemini API Key

### API Key Setup
To use the AI features of FitSwift, you need to set up a Google Gemini API key:

1. Get a Gemini API key from [Google AI Studio](https://ai.google.dev/)
2. Copy the `GenerativeAI-Info.template.plist` file to `GenerativeAI-Info.plist`
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key

```bash
cp GenerativeAI-Info.template.plist GenerativeAI-Info.plist
```

Then edit the `GenerativeAI-Info.plist` file to add your API key.

### Installation
1. Clone the repository
2. Set up the API key as described above
3. Open `FitSwift.xcodeproj` in Xcode
4. Build and run the project

## Dependencies
- [Google Generative AI Swift SDK](https://github.com/google/generative-ai-swift)
- SwiftUI
- HealthKit

## License
This project is licensed under the MIT License - see the LICENSE file for details.
