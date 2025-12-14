using System;
using Terena.Models.Enums;

namespace Terena.Models.SearchObjects
{
    public class BookingSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? VenueId { get; set; }
        public int? CourtId { get; set; }
        public DateTime? BookingDateFrom { get; set; }
        public DateTime? BookingDateTo { get; set; }
        public BookingStatus? Status { get; set; }
        public PaymentStatus? PaymentStatus { get; set; }
        public bool? IsRefunded { get; set; }
    }
}
