namespace Terena.Services.Interfaces;

public interface IEmailService
{
    Task SendBookingConfirmationEmailAsync(string toEmail, string userName, string bookingNumber, string venueName, DateTime bookingDate, string timeSlot, decimal totalPrice);
    Task SendBookingCancellationEmailAsync(string toEmail, string userName, string bookingNumber, string venueName, string reason);
    Task SendBookingReminderEmailAsync(string toEmail, string userName, string bookingNumber, string venueName, DateTime bookingDate, string timeSlot);
}
