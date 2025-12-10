using System.ComponentModel.DataAnnotations;
using Terena.Models.Enums;

namespace Terena.Models.Requests
{
    public class UserInsertRequest
    {
        [Required]
        public string Username { get; set; }
        [Required]
        [EmailAddress]
        public string Email { get; set; }
        [Required]
        public string Password { get; set; }
        public string? Phone { get; set; }
        public string? Country { get; set; }
        public string? Address { get; set; }
        public UserRole Role { get; set; }
    }
}
