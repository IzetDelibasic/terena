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
        
        public bool HasParking { get; set; }
        public bool HasShowers { get; set; }
        public bool HasLighting { get; set; }
        public bool HasChangingRooms { get; set; }
        public bool HasEquipmentRental { get; set; }
        public bool HasCafeBar { get; set; }
        public bool HasWaterFountain { get; set; }
        public bool HasSeatingArea { get; set; }
        
        public List<VenueAmenity> Amenities { get; set; }
        public List<OperatingHour> OperatingHours { get; set; }
        public CancellationPolicy? CancellationPolicy { get; set; }
        public Discount? Discount { get; set; }
        public int? CancellationPolicyHours { get; set; }
        public decimal? DiscountPercentage { get; set; }
        public int? DiscountThreshold { get; set; }
        public decimal? CancellationFeePercentage { get; set; }
        public int? RefundProcessingDays { get; set; }
        public ICollection<Court>? Courts { get; set; }
        public ICollection<Booking>? Bookings { get; set; }
        public ICollection<Review>? Reviews { get; set; }
        public ICollection<UserFavoriteVenue>? FavoritedBy { get; set; }
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
