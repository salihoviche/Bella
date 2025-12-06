using Bella.Model.Requests;
using Bella.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;

namespace Bella.WebAPI.Controllers
{
    public class OrderItemController : BaseCRUDController<OrderItemResponse, OrderItemSearchObject, OrderItemUpsertRequest, OrderItemUpsertRequest>
    {
        public OrderItemController(IOrderItemService service) : base(service)
        {
        }
    }
}
