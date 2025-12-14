namespace Terena.Models.DTOs
{
    public class CourtDTO
    {
        public int Id { get; set; }
        public int VenueId { get; set; }
        public string? VenueName { get; set; }
        public string CourtType { get; set; }
        public string Name { get; set; }
        public bool IsAvailable { get; set; }
    }
}
