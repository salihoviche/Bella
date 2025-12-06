using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class LengthController : BaseCRUDController<LengthResponse, LengthSearchObject, LengthUpsertRequest, LengthUpsertRequest>
    {
        public LengthController(ILengthService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<LengthResponse>> Get([FromQuery] LengthSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<LengthResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

