using Bella.Model.Requests;
using Bella.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;

namespace Bella.WebAPI.Controllers
{
    public class CartController : BaseCRUDController<CartResponse, CartSearchObject, CartUpsertRequest, CartUpsertRequest>
    {
        private readonly ICartService _cartService;

        public CartController(ICartService service) : base(service)
        {
            _cartService = service;
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<CartResponse>> GetByUserId(int userId)
        {
            var cart = await _cartService.GetByUserIdAsync(userId);
            if (cart == null)
                return NotFound();
            
            return Ok(cart);
        }

        [HttpGet("user/{userId}/summary")]
        public async Task<ActionResult<CartSummaryResponse>> GetCartSummary(int userId)
        {
            var summary = await _cartService.GetCartSummaryAsync(userId);
            return Ok(summary);
        }

        [HttpPost("user/{userId}/get-or-create")]
        public async Task<ActionResult<CartResponse>> GetOrCreateCart(int userId)
        {
            var cart = await _cartService.GetOrCreateCartForUserAsync(userId);
            return Ok(cart);
        }

        [HttpPost("user/{userId}/add-item")]
        public async Task<ActionResult<CartResponse>> AddItemToCart(int userId, [FromBody] AddItemToCartRequest request)
        {
            var cart = await _cartService.AddItemToCartAsync(userId, request.ProductId, request.Quantity);
            return Ok(cart);
        }

        [HttpPut("user/{userId}/update-item")]
        public async Task<ActionResult<CartResponse>> UpdateItemQuantity(int userId, [FromBody] UpdateItemQuantityRequest request)
        {
            var cart = await _cartService.UpdateItemQuantityAsync(userId, request.ProductId, request.Quantity);
            return Ok(cart);
        }

        [HttpDelete("user/{userId}/remove-item/{productId}")]
        public async Task<ActionResult<CartResponse>> RemoveItemFromCart(int userId, int productId)
        {
            var cart = await _cartService.RemoveItemFromCartAsync(userId, productId);
            return Ok(cart);
        }

        [HttpDelete("user/{userId}/clear")]
        public async Task<ActionResult<CartResponse>> ClearCart(int userId)
        {
            var cart = await _cartService.ClearCartAsync(userId);
            return Ok(cart);
        }

        [HttpDelete("{cartId}/deactivate/{userId}")]
        public async Task<IActionResult> DeactivateCart(int cartId, int userId)
        {
            var result = await _cartService.DeactivateCartAsync(cartId, userId);
            if (result)
                return Ok(new { message = "Cart deactivated successfully" });
            
            return BadRequest(new { message = "Failed to deactivate cart" });
        }
    }

    public class AddItemToCartRequest
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
    }

    public class UpdateItemQuantityRequest
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
    }
}
