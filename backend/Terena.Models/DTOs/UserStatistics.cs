namespace Terena.Models.DTOs
{
    public class UserStatistics
    {
        public int TotalBookings { get; set; }
        public int CompletedBookings { get; set; }
        public int CancelledBookings { get; set; }
        public decimal TotalSpent { get; set; }
        public decimal AveragePerBooking { get; set; }
        public int FavoriteVenueCount { get; set; }
        public string? FavoriteVenueName { get; set; }
    }
}
