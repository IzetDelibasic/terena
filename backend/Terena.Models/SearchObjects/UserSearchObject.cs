using Terena.Models.Enums;
using Terena.Models.SearchObjects;

namespace Terena.Models.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? Email { get; set; }
        public UserStatus? Status { get; set; }
        public string? Country { get; set; }
        public UserRole? Role { get; set; }
    }
}
