using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;

namespace Terena.Services.Interfaces
{
    public interface IBookingService : ICRUDService<BookingDTO, BookingSearchObject, BookingInsertRequest, BookingUpdateRequest>
    {
        Task<BookingDTO> ConfirmBookingAsync(int bookingId);
        Task<BookingDTO> CancelBookingAsync(int bookingId, string cancellationReason);
        Task<BookingDTO> CompleteBookingAsync(int bookingId);
        Task<BookingDTO> ProcessPaymentAsync(int bookingId, string transactionId);
        Task<BookingDTO> RefundBookingAsync(int bookingId, decimal? refundAmount = null);
        Task<List<string>> GetAvailableTimeSlotsAsync(int venueId, DateTime date, int? courtId = null);
        Task<int> GetMaxDurationForSlotAsync(int venueId, DateTime date, string timeSlot, int? courtId = null);
    }
}
