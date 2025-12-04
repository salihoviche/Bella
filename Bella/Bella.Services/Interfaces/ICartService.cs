using Bella.Model.SearchObjects;
using Bella.Model.Requests;
using Bella.Model.Responses;

namespace Bella.Services.Interfaces
{
    public interface ICartService : ICRUDService<CartResponse, CartSearchObject, CartUpsertRequest, CartUpsertRequest>
    {
        Task<List<CartResponse>> GetAllCartsForUserAsync(int userId);
        Task<CartResponse?> GetByUserIdAsync(int userId);
        Task<CartResponse> GetOrCreateCartForUserAsync(int userId);
        Task<bool> DeactivateCartAsync(int cartId, int userId);
        Task<CartSummaryResponse> GetCartSummaryAsync(int userId);
        Task<CartResponse> AddItemToCartAsync(int userId, int productId, int quantity);
        Task<CartResponse> UpdateItemQuantityAsync(int userId, int productId, int quantity);
        Task<CartResponse> RemoveItemFromCartAsync(int userId, int productId);
        Task<CartResponse> ClearCartAsync(int userId);
    }
}
