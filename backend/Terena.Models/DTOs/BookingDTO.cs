using System;
using Terena.Models.Enums;

namespace Terena.Models.DTOs
{
    public class BookingDTO
    {
        public int Id { get; set; }
        public string BookingNumber { get; set; }
        public int UserId { get; set; }
        public string? UserName { get; set; }
        public string? UserEmail { get; set; }
        public int VenueId { get; set; }
        public string? VenueName { get; set; }
        public string? VenueLocation { get; set; }
        public string? VenueAddress { get; set; }
        public string? VenueContactPhone { get; set; }
        public decimal VenueAverageRating { get; set; }
        public int VenueTotalReviews { get; set; }
        public int? CourtId { get; set; }
        public string? CourtName { get; set; }
        public int? CourtMaxCapacity { get; set; }
        public DateTime BookingDate { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal Duration { get; set; }
        public int NumberOfPlayers { get; set; }
        public bool IsGroupBooking { get; set; }
        public string? Notes { get; set; }
        public decimal PricePerHour { get; set; }
        public decimal SubtotalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal DiscountPercentage { get; set; }
        public decimal ServiceFee { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime? CancellationDeadline { get; set; }
        public BookingStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ConfirmedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime? CancelledAt { get; set; }
        public string? CancellationReason { get; set; }
        public PaymentStatus PaymentStatus { get; set; }
        public string? PaymentMethod { get; set; }
        public string? TransactionId { get; set; }
        public DateTime? PaidAt { get; set; }
        public bool IsRefunded { get; set; }
        public decimal? RefundAmount { get; set; }
        public DateTime? RefundedAt { get; set; }
    }
}
