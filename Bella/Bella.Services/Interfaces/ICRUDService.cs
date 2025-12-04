using Bella.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using Bella.Model.Responses;
using Bella.Model.Requests;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> where T : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
    {
        Task<T> CreateAsync(TInsert request);
        Task<T?> UpdateAsync(int id, TUpdate request);
        Task<bool> DeleteAsync(int id);
    }
}