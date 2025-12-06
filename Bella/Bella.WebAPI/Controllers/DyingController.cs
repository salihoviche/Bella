using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class DyingController : BaseCRUDController<DyingResponse, DyingSearchObject, DyingUpsertRequest, DyingUpsertRequest>
    {
        public DyingController(IDyingService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<DyingResponse>> Get([FromQuery] DyingSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<DyingResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

