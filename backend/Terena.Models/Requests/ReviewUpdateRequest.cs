using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class ReviewUpdateRequest
    {
        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }
        public string? Comment { get; set; }
    }
}
