using Microsoft.EntityFrameworkCore;
using Terena.Models.Messages;
using Terena.Services.Database;
using Terena.Services.Interfaces;
using Terena.Services.Messaging;

namespace Terena.Services;

public class NotificationService : INotificationService
{
    private readonly IRabbitMQProducer _rabbitMQProducer;
    private readonly TerenaDbContext _context;

    private const string BOOKING_CONFIRMATION_QUEUE = "booking_confirmations";
    private const string BOOKING_CANCELLATION_QUEUE = "booking_cancellations";
    private const string BOOKING_REMINDER_QUEUE = "booking_reminders";

    public NotificationService(IRabbitMQProducer rabbitMQProducer, TerenaDbContext context)
    {
        _rabbitMQProducer = rabbitMQProducer;
        _context = context;
    }

    public async Task SendBookingConfirmationAsync(BookingConfirmationMessage message)
    {
        try
        {
            _rabbitMQProducer.SendMessage(message, BOOKING_CONFIRMATION_QUEUE);
        }
        catch (Exception ex)
        {
            throw;
        }

        await Task.CompletedTask;
    }

    public async Task SendBookingCancellationAsync(int bookingId, int userId, string reason)
    {
        try
        {
            var booking = await _context.Bookings
                .Include(b => b.Venue)
                .Include(b => b.User)
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
            {
                throw new Exception("Booking not found");
            }

            var cancellationMessage = new BookingCancellationMessage
            {
                BookingId = bookingId,
                UserId = userId,
                UserEmail = booking.User?.Email ?? "N/A",
                UserName = booking.User?.Username ?? "N/A",
                BookingNumber = booking.BookingNumber,
                VenueName = booking.Venue?.Name ?? "N/A",
                Reason = reason,
                CancelledAt = DateTime.UtcNow
            };

            _rabbitMQProducer.SendMessage(cancellationMessage, BOOKING_CANCELLATION_QUEUE);
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    public async Task SendBookingReminderAsync(int bookingId)
    {
        try
        {
            var booking = await _context.Bookings
                .Include(b => b.Venue)
                .Include(b => b.User)
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
            {
                throw new Exception("Booking not found");
            }

            var reminderMessage = new BookingReminderMessage
            {
                BookingId = bookingId,
                UserId = booking.UserId,
                UserEmail = booking.User?.Email ?? "N/A",
                UserName = booking.User?.Username ?? "N/A",
                BookingNumber = booking.BookingNumber,
                VenueName = booking.Venue?.Name ?? "N/A",
                BookingDate = booking.BookingDate,
                TimeSlot = $"{booking.StartTime:HH:mm} - {booking.EndTime:HH:mm}"
            };

            _rabbitMQProducer.SendMessage(reminderMessage, BOOKING_REMINDER_QUEUE);
        }
        catch (Exception ex)
        {
            throw;
        }
    }
}
