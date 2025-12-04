using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface IHairstyleService : ICRUDService<HairstyleResponse, HairstyleSearchObject, HairstyleUpsertRequest, HairstyleUpsertRequest>
    {
    }
}

