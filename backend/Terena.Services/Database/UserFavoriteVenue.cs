using System;

namespace Terena.Services.Database
{
    public class UserFavoriteVenue
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
    }
}
