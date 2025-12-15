using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class FavoriteVenueInsertRequest
    {
        [Required]
        public int UserId { get; set; }
        [Required]
        public int VenueId { get; set; }
    }
}
