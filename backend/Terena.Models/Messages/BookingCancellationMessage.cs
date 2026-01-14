namespace Terena.Models.Messages;

public class BookingCancellationMessage
{
    public int BookingId { get; set; }
    public int UserId { get; set; }
    public string UserEmail { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string BookingNumber { get; set; } = string.Empty;
    public string VenueName { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public DateTime CancelledAt { get; set; }
}
