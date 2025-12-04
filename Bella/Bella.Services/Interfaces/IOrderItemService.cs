using Bella.Model.SearchObjects;
using Bella.Model.Requests;
using Bella.Model.Responses;

namespace Bella.Services.Interfaces
{
    public interface IOrderItemService : ICRUDService<OrderItemResponse, OrderItemSearchObject, OrderItemUpsertRequest, OrderItemUpsertRequest>
    {
    }
}
