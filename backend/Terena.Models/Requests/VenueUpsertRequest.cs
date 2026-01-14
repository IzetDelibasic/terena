using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class VenueUpsertRequest
    {
        [Required]
        public string Name { get; set; }
        [Required]
        public string Location { get; set; }
        [Required]
        public string Address { get; set; }
        [Required]
        public string SportType { get; set; }
        [Required]
        public string SurfaceType { get; set; }
        [Required]
        public decimal PricePerHour { get; set; }
        [Required]
        public int AvailableSlots { get; set; }
        public string Description { get; set; }
        [Required]
        [Phone]
        public string ContactPhone { get; set; }
        [Required]
        [EmailAddress]
        public string ContactEmail { get; set; }
        public string VenueImageUrl { get; set; }
        
        public List<string>? Amenities { get; set; }
        public bool HasParking { get; set; }
        public bool HasShowers { get; set; }
        public bool HasLighting { get; set; }
        public bool HasChangingRooms { get; set; }
        public bool HasEquipmentRental { get; set; }
        public bool HasCafeBar { get; set; }
        public bool HasWaterFountain { get; set; }
        public bool HasSeatingArea { get; set; }
        
        public List<OperatingHourRequest>? OperatingHours { get; set; }
        public CancellationPolicyRequest? CancellationPolicy { get; set; }
        public DiscountRequest? Discount { get; set; }
    }

    public class OperatingHourRequest
    {
        public string Day { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
    }

    public class CancellationPolicyRequest
    {
        public decimal Fee { get; set; }
    }

    public class DiscountRequest
    {
        public decimal Percentage { get; set; }
        public int ForBookings { get; set; }
    }
}
