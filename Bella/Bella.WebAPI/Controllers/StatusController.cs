using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class StatusController : BaseCRUDController<StatusResponse, StatusSearchObject, StatusUpsertRequest, StatusUpsertRequest>
    {
        public StatusController(IStatusService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<StatusResponse>> Get([FromQuery] StatusSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<StatusResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

