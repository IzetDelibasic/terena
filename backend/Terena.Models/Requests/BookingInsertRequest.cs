using System;
using System.ComponentModel.DataAnnotations;
using Terena.Models.Enums;

namespace Terena.Models.Requests
{
    public class BookingInsertRequest
    {
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public int VenueId { get; set; }
        
        public int? CourtId { get; set; }
        
        [Required]
        public DateTime BookingDate { get; set; }
        
        [Required]
        public DateTime StartTime { get; set; }
        
        [Required]
        public DateTime EndTime { get; set; }
        
        [Required]
        [Range(1, int.MaxValue)]
        public int NumberOfPlayers { get; set; }
        
        public bool IsGroupBooking { get; set; }
        
        public string? Notes { get; set; }
        
        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal PricePerHour { get; set; }
        
        public decimal? DiscountPercentage { get; set; }
        
        public string? PaymentMethod { get; set; }
    }
}
