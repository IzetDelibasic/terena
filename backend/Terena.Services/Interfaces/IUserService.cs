using System.Threading.Tasks;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;
using Terena.Services.Database;

namespace Terena.Services.Interfaces
{
    public interface IUserService : ICRUDService<UserModel, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<UserModel> BlockUser(int id, string reason);
        Task<UserModel> UnblockUser(int id);
        Task<UserStatistics> GetUserStatistics(int id);
    }
}
