using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class CourtUpdateRequest
    {
        [Required]
        public string CourtType { get; set; }
        [Required]
        public string Name { get; set; }
        public bool IsAvailable { get; set; }
    }
}
