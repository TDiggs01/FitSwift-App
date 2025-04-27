import SwiftUI
import HealthKit

extension HKWorkoutActivityType {

    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"

        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"

        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"

        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"
            
        // - iOS 14
        case .cardioDance:                  return "Cardio Dance"
        case .socialDance:                  return "Social Dance"
        case .pickleball:                   return "Pickleball"
        case .cooldown:                     return "Cooldown"

        // Catch-all
        default:                            return "Other"
        }
    }

    var image: String {
        let symbolName: String
        switch self {
        case .americanFootball:             symbolName =  "American Football"
        case .archery:                      symbolName =  "Archery"
        case .australianFootball:           symbolName =  "Australian Football"
        case .badminton:                    symbolName =  "Badminton"
        case .baseball:                     symbolName =  "Baseball"
        case .basketball:                   symbolName =  "Basketball"
        case .bowling:                      symbolName =  "Bowling"
        case .boxing:                       symbolName =  "Boxing"
        case .climbing:                     symbolName =  "Climbing"
        case .crossTraining:                symbolName =  "Cross Training"
        case .curling:                      symbolName =  "Curling"
        case .cycling:                      symbolName =  "Cycling"
        case .dance:                        symbolName =  "Dance"
        case .danceInspiredTraining:        symbolName =  "Dance Inspired Training"
        case .elliptical:                   symbolName =  "Elliptical"
        case .equestrianSports:             symbolName =  "Equestrian Sports"
        case .fencing:                      symbolName =  "Fencing"
        case .fishing:                      symbolName =  "Fishing"
        case .functionalStrengthTraining:   symbolName =  "Functional Strength Training"
        case .golf:                         symbolName =  "Golf"
        case .gymnastics:                   symbolName =  "Gymnastics"
        case .handball:                     symbolName =  "Handball"
        case .hiking:                       symbolName =  "Hiking"
        case .hockey:                       symbolName =  "Hockey"
        case .hunting:                      symbolName =  "Hunting"
        case .lacrosse:                     symbolName =  "Lacrosse"
        case .martialArts:                  symbolName =  "Martial Arts"
        case .mindAndBody:                  symbolName =  "Mind and Body"
        case .mixedMetabolicCardioTraining: symbolName =  "Mixed Metabolic Cardio Training"
        case .paddleSports:                 symbolName =  "Paddle Sports"
        case .play:                         symbolName =  "Play"
        case .preparationAndRecovery:       symbolName =  "Preparation and Recovery"
        case .racquetball:                  symbolName =  "Racquetball"
        case .rowing:                       symbolName =  "Rowing"
        case .rugby:                        symbolName =  "Rugby"
        case .running:                      symbolName =  "Running"
        case .sailing:                      symbolName =  "Sailing"
        case .skatingSports:                symbolName =  "Skating Sports"
        case .snowSports:                   symbolName =  "Snow Sports"
        case .soccer:                       symbolName =  "Soccer"
        case .softball:                     symbolName =  "Softball"
        case .squash:                       symbolName =  "Squash"
        case .stairClimbing:                symbolName =  "Stair Climbing"
        case .surfingSports:                symbolName =  "Surfing Sports"
        case .swimming:                     symbolName =  "Swimming"
        case .tableTennis:                  symbolName =  "Table Tennis"
        case .tennis:                       symbolName =  "Tennis"
        case .trackAndField:                symbolName =  "Track and Field"
        case .traditionalStrengthTraining:  symbolName =  "Traditional Strength Training"
        case .volleyball:                   symbolName =  "Volleyball"
        case .walking:                      symbolName =  "Walking"
        case .waterFitness:                 symbolName =  "Water Fitness"
        case .waterPolo:                    symbolName =  "Water Polo"
        case .waterSports:                  symbolName =  "Water Sports"
        case .wrestling:                    symbolName =  "Wrestling"
        case .yoga:                         symbolName =  "Yoga"

        // iOS 10
        case .barre:                        symbolName =  "Barre"
        case .coreTraining:                 symbolName =  "Core Training"
        case .crossCountrySkiing:           symbolName =  "Cross Country Skiing"
        case .downhillSkiing:               symbolName =  "Downhill Skiing"
        case .flexibility:                  symbolName =  "Flexibility"
        case .highIntensityIntervalTraining:    symbolName =  "High Intensity Interval Training"
        case .jumpRope:                     symbolName =  "Jump Rope"
        case .kickboxing:                   symbolName =  "Kickboxing"
        case .pilates:                      symbolName =  "Pilates"
        case .snowboarding:                 symbolName =  "Snowboarding"
        case .stairs:                       symbolName =  "Stairs"
        case .stepTraining:                 symbolName =  "Step Training"
        case .wheelchairWalkPace:           symbolName =  "Wheelchair Walk Pace"
        case .wheelchairRunPace:            symbolName =  "Wheelchair Run Pace"

        // iOS 11
        case .taiChi:                       symbolName =  "Tai Chi"
        case .mixedCardio:                  symbolName =  "Mixed Cardio"
        case .handCycling:                  symbolName =  "Hand Cycling"

        // iOS 13
        case .discSports:                   symbolName =  "Disc Sports"
        case .fitnessGaming:                symbolName =  "Fitness Gaming"
            
        // - iOS 14
        case .cardioDance:                  symbolName =  "Cardio Dance"
        case .socialDance:                  symbolName =  "Social Dance"
        case .pickleball:                   symbolName =  "Pickleball"
        case .cooldown:                     symbolName =  "Cooldown"

        // Catch-all
        default:                            symbolName =  "Other"
        }
        return symbolName
    }
    
    var color: Color {
        let defaultColor: Color = .gray
        switch self {
        case .running, .cycling, .hiking, .soccer, .tennis, .walking, .basketball, .kickboxing:
            return .green
        case .swimming:
            return .blue
        case .stairClimbing, .stairs:
            return .orange
        case .dance, .pilates, .taiChi, .yoga:
            return .red
        default:
            return defaultColor
        }
    }
}

