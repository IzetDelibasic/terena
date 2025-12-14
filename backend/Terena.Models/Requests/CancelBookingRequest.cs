using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class CancelBookingRequest
    {
        [Required]
        public string CancellationReason { get; set; }
    }
}
