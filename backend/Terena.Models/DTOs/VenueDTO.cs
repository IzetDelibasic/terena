namespace Terena.Models.DTOs
{
    public class VenueDTO
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
        public decimal AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public List<string> Amenities { get; set; }
        public List<OperatingHourDTO> OperatingHours { get; set; }
        public CancellationPolicyDTO CancellationPolicy { get; set; }
        public DiscountDTO Discount { get; set; }
    }

    public class OperatingHourDTO
    {
        public string Day { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
    }

    public class CancellationPolicyDTO
    {
        public DateTime FreeUntil { get; set; }
        public decimal Fee { get; set; }
    }

    public class DiscountDTO
    {
        public decimal Percentage { get; set; }
        public int ForBookings { get; set; }
    }
}
