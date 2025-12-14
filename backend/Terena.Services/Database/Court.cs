using System.Collections.Generic;

namespace Terena.Services.Database
{
    public class Court
    {
        public int Id { get; set; }
        public int VenueId { get; set; }
        public string CourtType { get; set; }
        public string Name { get; set; }
        public bool IsAvailable { get; set; }
        public string MaxCapacity { get; set; }
        public Venue Venue { get; set; }
        public ICollection<Booking> Bookings { get; set; }
    }
}
