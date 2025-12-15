using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Terena.Models.DTOs;
using Terena.Services.Database;

namespace Terena.Services
{
    public class FavoriteService
    {
        private readonly TerenaDbContext _context;

        public FavoriteService(TerenaDbContext context)
        {
            _context = context;
        }

        public async Task<FavoriteVenueDTO> AddFavoriteAsync(int userId, int venueId)
        {
            var existingFavorite = await _context.UserFavoriteVenues
                .FirstOrDefaultAsync(f => f.UserId == userId && f.VenueId == venueId);

            if (existingFavorite != null)
                throw new Exception("Venue is already in favorites!");

            var favorite = new UserFavoriteVenue
            {
                UserId = userId,
                VenueId = venueId,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserFavoriteVenues.Add(favorite);
            await _context.SaveChangesAsync();

            return await GetFavoriteByIdAsync(favorite.Id);
        }

        public async Task<bool> RemoveFavoriteAsync(int userId, int venueId)
        {
            var favorite = await _context.UserFavoriteVenues
                .FirstOrDefaultAsync(f => f.UserId == userId && f.VenueId == venueId);

            if (favorite == null)
                throw new Exception("Favorite not found!");

            _context.UserFavoriteVenues.Remove(favorite);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<FavoriteVenueDTO>> GetUserFavoritesAsync(int userId)
        {
            var favorites = await _context.UserFavoriteVenues
                .Where(f => f.UserId == userId)
                .Include(f => f.Venue)
                .ThenInclude(v => v.Reviews)
                .OrderByDescending(f => f.CreatedAt)
                .ToListAsync();

            return favorites.Select(f =>
            {
                var (rating, count) = Helpers.VenueRatingHelper.CalculateVenueRatingAndCount(f.Venue);
                return new FavoriteVenueDTO
                {
                    Id = f.Id,
                    CreatedAt = f.CreatedAt,
                    UserId = f.UserId,
                    VenueId = f.VenueId,
                    VenueName = f.Venue.Name,
                    VenueLocation = f.Venue.Location,
                    VenueSportType = f.Venue.SportType,
                    VenuePricePerHour = f.Venue.PricePerHour,
                    VenueImageUrl = f.Venue.VenueImageUrl,
                    VenueAverageRating = rating,
                    VenueTotalReviews = count
                };
            }).ToList();
        }

        public async Task<bool> IsFavoriteAsync(int userId, int venueId)
        {
            return await _context.UserFavoriteVenues
                .AnyAsync(f => f.UserId == userId && f.VenueId == venueId);
        }

        private async Task<FavoriteVenueDTO> GetFavoriteByIdAsync(int id)
        {
            var favorite = await _context.UserFavoriteVenues
                .Include(f => f.Venue)
                .ThenInclude(v => v.Reviews)
                .FirstOrDefaultAsync(f => f.Id == id);

            if (favorite == null)
                throw new Exception("Favorite not found!");

            var (rating, count) = Helpers.VenueRatingHelper.CalculateVenueRatingAndCount(favorite.Venue);
            return new FavoriteVenueDTO
            {
                Id = favorite.Id,
                CreatedAt = favorite.CreatedAt,
                UserId = favorite.UserId,
                VenueId = favorite.VenueId,
                VenueName = favorite.Venue.Name,
                VenueLocation = favorite.Venue.Location,
                VenueSportType = favorite.Venue.SportType,
                VenuePricePerHour = favorite.Venue.PricePerHour,
                VenueImageUrl = favorite.Venue.VenueImageUrl,
                VenueAverageRating = rating,
                VenueTotalReviews = count
            };
        }
    }
}
