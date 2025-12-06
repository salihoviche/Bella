using Bella.Model.Requests;
using Bella.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;

namespace Bella.WebAPI.Controllers
{
    public class CartItemController : BaseCRUDController<CartItemResponse, CartItemSearchObject, CartItemUpsertRequest, CartItemUpsertRequest>
    {
        public CartItemController(ICartItemService service) : base(service)
        {
        }
    }
}
