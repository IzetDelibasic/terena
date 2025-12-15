using System;

namespace Terena.Models.DTOs
{
    public class FavoriteVenueDTO
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public int UserId { get; set; }
        public int VenueId { get; set; }
        public string VenueName { get; set; }
        public string VenueLocation { get; set; }
        public string VenueSportType { get; set; }
        public decimal VenuePricePerHour { get; set; }
        public string VenueImageUrl { get; set; }
        public decimal? VenueAverageRating { get; set; }
        public int VenueTotalReviews { get; set; }
    }
}
