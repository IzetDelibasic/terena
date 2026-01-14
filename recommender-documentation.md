# Recommender System Documentation

## Terena - Sports Court Booking Application

---

## 1. Overview

The Terena application implements a **content-based recommendation system** that suggests sports venues to users based on their historical behavior and preferences. The system analyzes user activity (bookings, favorites, and reviews) to build a personalized preference profile and then calculates similarity scores for venues the user hasn't visited yet.

---

## 2. Implementation Description

### 2.1 Algorithm Type

The recommender system uses a **content-based filtering** approach, which recommends items based on the features of items the user has previously interacted with.

### 2.2 Data Sources

The system collects data from three sources for each user:

| Data Source   | Description                            | Purpose                                           |
| ------------- | -------------------------------------- | ------------------------------------------------- |
| **Bookings**  | User's previous venue reservations     | Determine preferred sport types and surface types |
| **Favorites** | Venues marked as favorites by the user | Identify preferred amenities                      |
| **Reviews**   | Venues the user has reviewed and rated | Set minimum rating threshold                      |

### 2.3 User Preference Profile

Based on collected data, the system builds a `UserPreferenceProfile` containing:

| Preference                | Description                                                                             | Weight        |
| ------------------------- | --------------------------------------------------------------------------------------- | ------------- |
| `PreferredSportType`      | Most frequently booked sport type (football, basketball, tennis, etc.)                  | 40 points max |
| `PreferredSurfaceType`    | Most frequently booked surface type (grass, artificial turf, hardcourt)                 | 20 points max |
| `PrefersParking`          | Whether user prefers venues with parking                                                | 5 points      |
| `PrefersShowers`          | Whether user prefers venues with showers                                                | 5 points      |
| `PrefersLighting`         | Whether user prefers venues with lighting                                               | 5 points      |
| `PrefersChangingRooms`    | Whether user prefers venues with changing rooms                                         | 5 points      |
| `PrefersEquipmentRental`  | Whether user prefers venues with equipment rental                                       | 5 points      |
| `PrefersCafeBar`          | Whether user prefers venues with cafe/bar                                               | 5 points      |
| `MinimumRatingPreference` | Minimum acceptable venue rating (default 3.0, raised to 4.0 if user gives high ratings) | 10 points max |

### 2.4 Similarity Score Calculation

For each venue not yet booked or favorited by the user, the system calculates a similarity score:

```
Total Score (max 100 points):
├── Sport Type Match:      up to 40 points (weighted by booking frequency)
├── Surface Type Match:    up to 20 points (weighted by booking frequency)
├── Amenity Matches:       up to 30 points (5 points each)
│   ├── Parking
│   ├── Showers
│   ├── Lighting
│   ├── Changing Rooms
│   ├── Equipment Rental
│   └── Cafe/Bar
└── Rating Bonus:          up to 10 points (scaled by averageRating / 5)
```

### 2.5 Algorithm Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    RECOMMENDATION ALGORITHM                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. FETCH USER DATA                                              │
│     ├── Get user's booking history                               │
│     ├── Get user's favorite venues                               │
│     └── Get user's reviews                                       │
│                                                                  │
│  2. BUILD USER PREFERENCE PROFILE                                │
│     ├── Analyze most booked sport types                          │
│     ├── Analyze most booked surface types                        │
│     ├── Determine amenity preferences (>50% = preferred)         │
│     └── Set minimum rating threshold                             │
│                                                                  │
│  3. CALCULATE SIMILARITY SCORES                                  │
│     For each venue NOT in user's bookings/favorites:             │
│     ├── +40 pts if sport type matches (weighted)                 │
│     ├── +20 pts if surface type matches (weighted)               │
│     ├── +5 pts for each matching amenity                         │
│     └── +10 pts max for high-rated venues                        │
│                                                                  │
│  4. RETURN TOP N RECOMMENDATIONS                                 │
│     └── Sort by score DESC, return requested count               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Source Code Location

### 3.1 Main Logic

**File Path:** `backend/Terena.Services/RecommendationService.cs`

This file contains:

- `GetRecommendedVenuesAsync()` - Main recommendation method
- `BuildUserPreferenceProfile()` - Builds user preference profile from historical data
- `CalculateSimilarityScore()` - Calculates similarity score between venue and user preferences
- `UserPreferenceProfile` - Internal class representing user preferences

### 3.2 API Endpoint

**File Path:** `backend/Terena.API/Controllers/RecommendationController.cs`

**API Route:** `GET /api/Recommendation/GetRecommendations/{userId}?count=10`

---

## 4. Source Code Screenshots

### 4.1 RecommendationService.cs - Main Logic

**Path:** `backend/Terena.Services/RecommendationService.cs`

```csharp
public async Task<List<VenueDTO>> GetRecommendedVenuesAsync(int userId, int count = 10)
{
    var userBookings = await _context.Bookings
        .Include(b => b.Venue)
        .Where(b => b.UserId == userId)
        .ToListAsync();

    var userFavorites = await _context.UserFavoriteVenues
        .Include(f => f.Venue)
        .Where(f => f.UserId == userId)
        .ToListAsync();

    var userReviews = await _context.Reviews
        .Include(r => r.Venue)
        .Where(r => r.UserId == userId)
        .ToListAsync();

    var userPreferences = BuildUserPreferenceProfile(userBookings, userFavorites, userReviews);

    var allVenues = await _context.Venues
        .Where(v => !v.IsDeleted)
        .Include(v => v.Reviews)
        .ToListAsync();

    var venueScores = new List<(Venue venue, double score)>();

    foreach (var venue in allVenues)
    {
        bool alreadyBooked = userBookings.Any(b => b.VenueId == venue.Id);
        bool alreadyFavorited = userFavorites.Any(f => f.VenueId == venue.Id);

        if (!alreadyBooked && !alreadyFavorited)
        {
            double similarityScore = CalculateSimilarityScore(venue, userPreferences);
            venueScores.Add((venue, similarityScore));
        }
    }

    var recommendedVenues = venueScores
        .OrderByDescending(v => v.score)
        .Take(count)
        .Select(v => v.venue)
        .ToList();

    return recommendedVenues.Adapt<List<VenueDTO>>();
}
```

### 4.2 Similarity Score Calculation

```csharp
private double CalculateSimilarityScore(Venue venue, UserPreferenceProfile preferences)
{
    double score = 0.0;

    // Sport type match (40 points max)
    if (!string.IsNullOrEmpty(preferences.PreferredSportType) &&
        venue.SportType == preferences.PreferredSportType)
    {
        score += 40.0 * preferences.SportTypeWeight;
    }

    // Surface type match (20 points max)
    if (!string.IsNullOrEmpty(preferences.PreferredSurfaceType) &&
        venue.SurfaceType == preferences.PreferredSurfaceType)
    {
        score += 20.0 * preferences.SurfaceTypeWeight;
    }

    // Amenity matches (5 points each, 30 points max)
    if (preferences.PrefersParking && venue.HasParking) score += 5.0;
    if (preferences.PrefersShowers && venue.HasShowers) score += 5.0;
    if (preferences.PrefersLighting && venue.HasLighting) score += 5.0;
    if (preferences.PrefersChangingRooms && venue.HasChangingRooms) score += 5.0;
    if (preferences.PrefersEquipmentRental && venue.HasEquipmentRental) score += 5.0;
    if (preferences.PrefersCafeBar && venue.HasCafeBar) score += 5.0;

    // Rating bonus (10 points max)
    var averageRating = venue.Reviews?.Any() == true
        ? venue.Reviews.Average(r => r.Rating)
        : 0;

    if (averageRating >= preferences.MinimumRatingPreference)
    {
        score += 10.0 * (averageRating / 5.0);
    }

    return score;
}
```

---

## 5. Application Screenshots

### 5.1 Recommendations Display in Mobile App

**Location in App:** Home Screen > "Recommended for You" section

<img src="https://i.ibb.co/bjPTjHnt/image.png" alt="Recommendation system"/>

### 5.2 API Response Example

```json
GET /api/Recommendation/GetRecommendations/1?count=5

[
  {
    "id": 15,
    "name": "Sport Center Arena",
    "sportType": "Football",
    "surfaceType": "Artificial Turf",
    "pricePerHour": 50.00,
    "averageRating": 4.5,
    "hasParking": true,
    "hasLighting": true
  },
  {
    "id": 8,
    "name": "Green Field Stadium",
    "sportType": "Football",
    "surfaceType": "Natural Grass",
    "pricePerHour": 45.00,
    "averageRating": 4.2,
    "hasParking": true,
    "hasShowers": true
  }
]
```

---

## 6. Summary

The Terena recommendation system provides personalized venue suggestions by:

1. **Analyzing user behavior** - Bookings, favorites, and reviews
2. **Building preference profiles** - Sport types, surface types, and amenities
3. **Calculating similarity scores** - Weighted scoring based on multiple factors
4. **Filtering already visited venues** - Only suggesting new venues
5. **Ranking by relevance** - Returning top N most relevant recommendations

This approach ensures users discover new venues that match their preferences, improving user engagement and satisfaction.
