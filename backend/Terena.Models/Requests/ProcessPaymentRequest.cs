using System.ComponentModel.DataAnnotations;

namespace Terena.Models.Requests
{
    public class ProcessPaymentRequest
    {
        [Required]
        public string TransactionId { get; set; }
    }
}
