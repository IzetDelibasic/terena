using System;
using System.ComponentModel.DataAnnotations;
using Terena.Models.Enums;

namespace Terena.Models.Requests
{
    public class BookingUpdateRequest
    {
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public BookingStatus? Status { get; set; }
        public string? CancellationReason { get; set; }
        public PaymentStatus? PaymentStatus { get; set; }
        public string? PaymentMethod { get; set; }
        public string? TransactionId { get; set; }
    }
}
