using System;
using System.Collections.Generic;
using Terena.Models.Enums;

namespace Terena.Services.Database
{
    public class User : ISoftDeletable
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string? Phone { get; set; }
        public string? Country { get; set; }
        public string? Address { get; set; }
        public DateTime RegistrationDate { get; set; }
        public DateTime? LastLogin { get; set; }
        public UserStatus Status { get; set; }
        public string? BlockReason { get; set; }
        public DateTime? BlockedAt { get; set; }
        public UserRole Role { get; set; }
        
        public bool IsDeleted { get; set; }
        public DateTime? DeleteTime { get; set; }

        public ICollection<Booking> Bookings { get; set; }
    }
}
