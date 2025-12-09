using System;
using System.Collections.Generic;

namespace Terena.Services.Database
{
    public class Venue
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public string Address { get; set; }
        public string SportType { get; set; }
        public string SurfaceType { get; set; }
        public decimal PricePerHour { get; set; }
        public int AvailableSlots { get; set; }
        public string Description { get; set; }
        public string ContactPhone { get; set; }
        public string ContactEmail { get; set; }
        public string VenueImageUrl { get; set; }
        public List<VenueAmenity> Amenities { get; set; }
        public List<OperatingHour> OperatingHours { get; set; }
        public CancellationPolicy? CancellationPolicy { get; set; }
        public Discount? Discount { get; set; }
    }

    public class VenueAmenity
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool IsAvailable { get; set; }
        public int VenueId { get; set; }
    }

    public class OperatingHour
    {
        public int Id { get; set; }
        public string Day { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
    }

    public class CancellationPolicy
    {
        public int Id { get; set; }
        public DateTime FreeUntil { get; set; }
        public decimal Fee { get; set; }
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
    }

    public class Discount
    {
        public int Id { get; set; }
        public decimal Percentage { get; set; }
        public int ForBookings { get; set; }
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
    }
}
