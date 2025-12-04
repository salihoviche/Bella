using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface IManufacturerService : ICRUDService<ManufacturerResponse, ManufacturerSearchObject, ManufacturerUpsertRequest, ManufacturerUpsertRequest>
    {
    }
}

