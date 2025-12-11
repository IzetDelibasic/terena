namespace Terena.Models.SearchObjects
{
    public class CourtSearchObject : BaseSearchObject
    {
        public int? VenueId { get; set; }
        public string? CourtType { get; set; }
        public bool? IsAvailable { get; set; }
        public string? Name { get; set; }
    }
}
