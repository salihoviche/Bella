using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface IGenderService : ICRUDService<GenderResponse, GenderSearchObject, GenderUpsertRequest, GenderUpsertRequest>
    {
    }
} 