using Terena.Models.Enums;

namespace Terena.Models.Requests
{
    public class UserInsertRequest
    {
        public string Username { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string? Phone { get; set; }
        public string? Country { get; set; }
        public string? Address { get; set; }
        public UserRole Role { get; set; }
    }
}
