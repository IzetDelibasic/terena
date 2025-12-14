using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class CourtInsertRequest
    {
        public int VenueId { get; set; }
        [Required]
        public string CourtType { get; set; }
        [Required]
        public string Name { get; set; }
        public bool IsAvailable { get; set; } = true;
        [Required]
        public string MaxCapacity { get; set; }
    }
}
