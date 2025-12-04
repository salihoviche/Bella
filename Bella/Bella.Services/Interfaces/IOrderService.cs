using Bella.Model.SearchObjects;
using Bella.Model.Requests;
using Bella.Model.Responses;

namespace Bella.Services.Interfaces
{
    public interface IOrderService : ICRUDService<OrderResponse, OrderSearchObject, OrderUpsertRequest, OrderUpsertRequest>
    {
        Task<OrderResponse> CreateOrderFromCartAsync(int userId);
        Task<List<OrderResponse>> GetOrdersByUserAsync(int userId);
    }
}
