using System;

namespace Terena.Models.DTOs
{
    public class ReviewDTO
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
        public int UserId { get; set; }
        public string UserUsername { get; set; }
        public int VenueId { get; set; }
        public string VenueName { get; set; }
        public int? BookingId { get; set; }
    }
}
