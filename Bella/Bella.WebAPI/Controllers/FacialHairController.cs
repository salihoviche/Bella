using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class FacialHairController : BaseCRUDController<FacialHairResponse, FacialHairSearchObject, FacialHairUpsertRequest, FacialHairUpsertRequest>
    {
        public FacialHairController(IFacialHairService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<FacialHairResponse>> Get([FromQuery] FacialHairSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<FacialHairResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

