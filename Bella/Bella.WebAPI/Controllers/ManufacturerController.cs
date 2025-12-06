using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class ManufacturerController : BaseCRUDController<ManufacturerResponse, ManufacturerSearchObject, ManufacturerUpsertRequest, ManufacturerUpsertRequest>
    {
        public ManufacturerController(IManufacturerService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<ManufacturerResponse>> Get([FromQuery] ManufacturerSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<ManufacturerResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

