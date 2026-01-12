namespace Terena.Models.Requests
{
    public class CreatePaymentIntentRequest
    {
        public decimal Amount { get; set; }
        public string? Description { get; set; }
    }
}
