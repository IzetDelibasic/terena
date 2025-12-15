namespace Terena.Models.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? VenueId { get; set; }
        public int? BookingId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
    }
}
