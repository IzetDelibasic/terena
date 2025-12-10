using System;
using System.Collections.Generic;
using Terena.Models.Enums;

namespace Terena.Services.Database
{
    public class Booking : ISoftDeletable
    {
        public int Id { get; set; }
        public string BookingNumber { get; set; }
        
        public int UserId { get; set; }
        public User User { get; set; }
        
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
        
        public int? CourtId { get; set; }
        public Court? Court { get; set; }
        
        public DateTime BookingDate { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal Duration { get; set; }
        
        public decimal PricePerHour { get; set; }
        public decimal TotalPrice { get; set; }
        
        public BookingStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ConfirmedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime? CancelledAt { get; set; }
        public string? CancellationReason { get; set; }
        
        public PaymentStatus PaymentStatus { get; set; }
        public string? StripePaymentIntentId { get; set; }
        public string? StripeChargeId { get; set; }
        public string? StripeRefundId { get; set; }
        public string? PaymentMethod { get; set; }
        public string? TransactionId { get; set; }
        public DateTime? PaidAt { get; set; }
        
        public bool IsRefunded { get; set; }
        public decimal? RefundAmount { get; set; }
        public DateTime? RefundedAt { get; set; }
        
        public bool IsDeleted { get; set; }
        public DateTime? DeleteTime { get; set; }
    }
}
