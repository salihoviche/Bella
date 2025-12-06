using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class HairstyleController : BaseCRUDController<HairstyleResponse, HairstyleSearchObject, HairstyleUpsertRequest, HairstyleUpsertRequest>
    {
        public HairstyleController(IHairstyleService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<HairstyleResponse>> Get([FromQuery] HairstyleSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<HairstyleResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

