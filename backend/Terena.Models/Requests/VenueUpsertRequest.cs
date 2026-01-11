namespace Terena.Models.Requests
{
    public class VenueUpsertRequest
    {
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
        public DateTime FreeUntil { get; set; }
        public decimal Fee { get; set; }
    }

    public class DiscountRequest
    {
        public decimal Percentage { get; set; }
        public int ForBookings { get; set; }
    }
}
