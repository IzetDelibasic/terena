using Terena.Models.Messages;

namespace Terena.Services.Interfaces;

public interface INotificationService
{
    Task SendBookingConfirmationAsync(BookingConfirmationMessage message);
    Task SendBookingCancellationAsync(int bookingId, int userId, string reason);
    Task SendBookingReminderAsync(int bookingId);
}
