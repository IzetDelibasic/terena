using System;
using Terena.Models.Enums;

namespace Terena.Models.DTOs
{
    public class UserModel
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string? Phone { get; set; }
        public string? Country { get; set; }
        public string? Address { get; set; }
        public DateTime RegistrationDate { get; set; }
        public DateTime? LastLogin { get; set; }
        public UserStatus Status { get; set; }
        public string? BlockReason { get; set; }
        public DateTime? BlockedAt { get; set; }
        public UserRole Role { get; set; }
    }
}
