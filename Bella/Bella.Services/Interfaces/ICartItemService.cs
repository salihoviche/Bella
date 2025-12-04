using Bella.Model.SearchObjects;
using Bella.Model.Requests;
using Bella.Model.Responses;

namespace Bella.Services.Interfaces
{
    public interface ICartItemService : ICRUDService<CartItemResponse, CartItemSearchObject, CartItemUpsertRequest, CartItemUpsertRequest>
    {
    }
}
