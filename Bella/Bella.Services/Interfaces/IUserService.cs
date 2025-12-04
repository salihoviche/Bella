using Bella.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using Bella.Model.Responses;
using Bella.Model.Requests;
using Bella.Model.SearchObjects;
using Bella.Services.Services;

namespace Bella.Services.Interfaces
{
    public interface IUserService : IService<UserResponse, UserSearchObject>
    {
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
    }
}