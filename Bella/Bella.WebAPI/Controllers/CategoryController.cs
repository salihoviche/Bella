using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class CategoryController : BaseCRUDController<CategoryResponse, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        public CategoryController(ICategoryService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<CategoryResponse>> Get([FromQuery] CategorySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<CategoryResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}

