using System;

namespace Terena.Services.Database
{
    public class Review
    {
        public int Id { get; set; }
        public int Rating { get; set; } 
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
        public int? BookingId { get; set; }
        public Booking? Booking { get; set; }
    }
}
