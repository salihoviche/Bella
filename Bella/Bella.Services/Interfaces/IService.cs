using Bella.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using Bella.Model.Responses;
using Bella.Model.Requests;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}