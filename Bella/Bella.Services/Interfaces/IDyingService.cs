using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface IDyingService : ICRUDService<DyingResponse, DyingSearchObject, DyingUpsertRequest, DyingUpsertRequest>
    {
    }
}

