using Microsoft.EntityFrameworkCore;
using Mapster;
using Terena.Models.DTOs;
using Terena.Services.Database;
using Terena.Services.Interfaces;

namespace Terena.Services;

public class RecommendationService : IRecommendationService
{
    private readonly TerenaDbContext _context;

    public RecommendationService(TerenaDbContext context)
    {
        _context = context;
    }

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
            .Include(v => v.CancellationPolicy)
            .Include(v => v.Discount)
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

        var result = recommendedVenues.Adapt<List<VenueDTO>>();

        return result;
    }

    private UserPreferenceProfile BuildUserPreferenceProfile(
        List<Booking> bookings,
        List<UserFavoriteVenue> favorites,
        List<Review> reviews)
    {
        var profile = new UserPreferenceProfile();

        var sportTypeBookings = bookings
            .Where(b => b.Venue?.SportType != null)
            .GroupBy(b => b.Venue.SportType)
            .OrderByDescending(g => g.Count())
            .ToList();

        if (sportTypeBookings.Any())
        {
            profile.PreferredSportType = sportTypeBookings.First().Key;
            profile.SportTypeWeight = (double)sportTypeBookings.First().Count() / bookings.Count;
        }

        var surfaceTypeBookings = bookings
            .Where(b => b.Venue?.SurfaceType != null)
            .GroupBy(b => b.Venue.SurfaceType)
            .OrderByDescending(g => g.Count())
            .ToList();

        if (surfaceTypeBookings.Any())
        {
            profile.PreferredSurfaceType = surfaceTypeBookings.First().Key;
            profile.SurfaceTypeWeight = (double)surfaceTypeBookings.First().Count() / bookings.Count;
        }

        var allVenues = bookings.Select(b => b.Venue)
            .Concat(favorites.Select(f => f.Venue))
            .Where(v => v != null)
            .ToList();

        if (allVenues.Any())
        {
            profile.PrefersParking = allVenues.Count(v => v.HasParking) > allVenues.Count / 2;
            profile.PrefersShowers = allVenues.Count(v => v.HasShowers) > allVenues.Count / 2;
            profile.PrefersLighting = allVenues.Count(v => v.HasLighting) > allVenues.Count / 2;
            profile.PrefersChangingRooms = allVenues.Count(v => v.HasChangingRooms) > allVenues.Count / 2;
            profile.PrefersEquipmentRental = allVenues.Count(v => v.HasEquipmentRental) > allVenues.Count / 2;
            profile.PrefersCafeBar = allVenues.Count(v => v.HasCafeBar) > allVenues.Count / 2;
        }

        var highRatedReviews = reviews.Where(r => r.Rating >= 4).ToList();
        if (highRatedReviews.Any())
        {
            profile.MinimumRatingPreference = 4.0;
        }

        return profile;
    }

    private double CalculateSimilarityScore(Venue venue, UserPreferenceProfile preferences)
    {
        double score = 0.0;

        if (!string.IsNullOrEmpty(preferences.PreferredSportType) &&
            venue.SportType == preferences.PreferredSportType)
        {
            score += 40.0 * preferences.SportTypeWeight;
        }

        if (!string.IsNullOrEmpty(preferences.PreferredSurfaceType) &&
            venue.SurfaceType == preferences.PreferredSurfaceType)
        {
            score += 20.0 * preferences.SurfaceTypeWeight;
        }

        if (preferences.PrefersParking && venue.HasParking) score += 5.0;
        if (preferences.PrefersShowers && venue.HasShowers) score += 5.0;
        if (preferences.PrefersLighting && venue.HasLighting) score += 5.0;
        if (preferences.PrefersChangingRooms && venue.HasChangingRooms) score += 5.0;
        if (preferences.PrefersEquipmentRental && venue.HasEquipmentRental) score += 5.0;
        if (preferences.PrefersCafeBar && venue.HasCafeBar) score += 5.0;

        var averageRating = venue.Reviews?.Any() == true
            ? venue.Reviews.Average(r => r.Rating)
            : 0;

        if (averageRating >= preferences.MinimumRatingPreference)
        {
            score += 10.0 * (averageRating / 5.0); 
        }

        return score;
    }

    private class UserPreferenceProfile
    {
        public string? PreferredSportType { get; set; }
        public double SportTypeWeight { get; set; } = 1.0;

        public string? PreferredSurfaceType { get; set; }
        public double SurfaceTypeWeight { get; set; } = 1.0;

        public bool PrefersParking { get; set; }
        public bool PrefersShowers { get; set; }
        public bool PrefersLighting { get; set; }
        public bool PrefersChangingRooms { get; set; }
        public bool PrefersEquipmentRental { get; set; }
        public bool PrefersCafeBar { get; set; }

        public double MinimumRatingPreference { get; set; } = 3.0;
    }
}
