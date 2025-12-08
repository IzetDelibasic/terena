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
        public List<string> Amenities { get; set; }
        public List<OperatingHourRequest> OperatingHours { get; set; }
        public CancellationPolicyRequest CancellationPolicy { get; set; }
        public DiscountRequest Discount { get; set; }
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
