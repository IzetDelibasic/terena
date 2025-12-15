using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class ReviewInsertRequest
    {
        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }
        public string? Comment { get; set; }
        [Required]
        public int UserId { get; set; }
        [Required]
        public int VenueId { get; set; }
        public int? BookingId { get; set; }
    }
}
