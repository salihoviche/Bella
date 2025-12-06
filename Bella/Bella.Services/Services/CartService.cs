using Bella.Services.Database;
using Bella.Model.Responses;
using Bella.Model.Requests;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;

namespace Bella.Services.Services
{
    public class CartService : BaseCRUDService<CartResponse, CartSearchObject, Cart, CartUpsertRequest, CartUpsertRequest>, ICartService
    {
        public CartService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Cart> ApplyFilter(IQueryable<Cart> query, CartSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(c => c.UserId == search.UserId.Value);

            if (search.IsActive.HasValue)
                query = query.Where(c => c.IsActive == search.IsActive.Value);

            if (search.CreatedFrom.HasValue)
                query = query.Where(c => c.CreatedAt >= search.CreatedFrom.Value);

            if (search.CreatedTo.HasValue)
                query = query.Where(c => c.CreatedAt <= search.CreatedTo.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(c => c.User.Username.Contains(search.FTS) || 
                                       c.User.Email.Contains(search.FTS));

            return query;
        }

        public override async Task<PagedResult<CartResponse>> GetAsync(CartSearchObject search)
        {
            var query = _context.Carts.AsQueryable();
            query = ApplyFilter(query, search);

            // Always include User and CartItems for mapping
            query = query.Include(c => c.User)
                        .Include(c => c.CartItems)
                            .ThenInclude(ci => ci.Product);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            
            return new PagedResult<CartResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<CartResponse?> GetByIdAsync(int id)
        {
            var cart = await _context.Carts
                .Include(c => c.User)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.Id == id);

            return cart != null ? MapToResponse(cart) : null;
        }

        protected override async Task BeforeInsert(Cart entity, CartUpsertRequest request)
        {
            // Set creation timestamp
            entity.CreatedAt = DateTime.Now;
            entity.IsActive = true;
            
            // Ensure UserId is set
            if (request.UserId <= 0)
                throw new ArgumentException("UserId is required");
            
            entity.UserId = request.UserId;
        }

        protected override async Task BeforeUpdate(Cart entity, CartUpsertRequest request)
        {
            // Set update timestamp
            entity.UpdatedAt = DateTime.Now;
            
            // Ensure UserId cannot be changed
            if (request.UserId != entity.UserId)
                throw new ArgumentException("UserId cannot be changed");
        }

        protected override CartResponse MapToResponse(Cart entity)
        {
            var cartItems = entity.CartItems?.Select(ci => new CartItemResponse
            {
                Id = ci.Id,
                Quantity = ci.Quantity,
                CreatedAt = ci.CreatedAt,
                UpdatedAt = ci.UpdatedAt,
                CartId = ci.CartId,
                ProductId = ci.ProductId,
                ProductName = ci.Product?.Name ?? string.Empty,
                ProductPrice = ci.Product?.Price ?? 0,
                ProductPicture = ci.Product?.Picture
            }).ToList() ?? new List<CartItemResponse>();

            return new CartResponse
            {
                Id = entity.Id,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                ExpiresAt = entity.ExpiresAt,
                IsActive = entity.IsActive,
                UserId = entity.UserId,
                UserFullName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(),
                CartItems = cartItems
            };
        }

        public async Task<List<CartResponse>> GetAllCartsForUserAsync(int userId)
        {
            var carts = await _context.Carts
                .Include(c => c.User)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                .Where(c => c.UserId == userId)
                .ToListAsync();

            return carts.Select(MapToResponse).ToList();
        }

        public async Task<CartResponse?> GetByUserIdAsync(int userId)
        {
            var cart = await _context.Carts
                .Include(c => c.User)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            return cart != null ? MapToResponse(cart) : null;
        }

        public async Task<CartResponse> GetOrCreateCartForUserAsync(int userId)
        {
            // First, try to get any existing cart for this user
            var existingCart = await _context.Carts
                .Include(c => c.User)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (existingCart != null)
            {
                // If cart exists but is inactive, reactivate it
                if (!existingCart.IsActive)
                {
                    existingCart.IsActive = true;
                    existingCart.UpdatedAt = DateTime.Now;
                    await _context.SaveChangesAsync();
                }
                
                return MapToResponse(existingCart);
            }

            // Only create a new cart if no cart exists at all for this user
            var cartRequest = new CartUpsertRequest { UserId = userId };
            var newCart = await CreateAsync(cartRequest);
            return newCart;
        }

        public async Task<bool> DeactivateCartAsync(int cartId, int userId)
        {
            var cart = await _context.Carts
                .FirstOrDefaultAsync(c => c.Id == cartId && c.UserId == userId);

            if (cart == null)
                return false;

            cart.IsActive = false;
            cart.UpdatedAt = DateTime.Now;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<CartSummaryResponse> GetCartSummaryAsync(int userId)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                return new CartSummaryResponse
                {
                    UserId = userId,
                    TotalItems = 0,
                    TotalAmount = 0
                };

            return new CartSummaryResponse
            {
                UserId = userId,
                CartId = cart.Id,
                TotalItems = cart.TotalItems,
                TotalAmount = cart.TotalAmount
            };
        }

        public async Task<CartResponse> AddItemToCartAsync(int userId, int productId, int quantity)
        {
            // Get or create cart for user
            var cart = await GetOrCreateCartForUserAsync(userId);
            
            // Check if CartItem already exists for this CartId and ProductId
            var existingCartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == productId);

            if (existingCartItem != null)
            {
                // If it exists: increment Quantity and set UpdatedAt
                existingCartItem.Quantity += quantity;
                existingCartItem.UpdatedAt = DateTime.Now;
            }
            else
            {
                // If not: create a new CartItem
                var newCartItem = new CartItem
                {
                    CartId = cart.Id,
                    ProductId = productId,
                    Quantity = quantity,
                    CreatedAt = DateTime.Now
                };
                
                _context.CartItems.Add(newCartItem);
            }

            // Save changes to DbContext
            await _context.SaveChangesAsync();
            
            // Return the updated Cart
            return await GetByUserIdAsync(userId) ?? cart;
        }

        public async Task<CartResponse> UpdateItemQuantityAsync(int userId, int productId, int quantity)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                throw new ArgumentException("No active cart found for user");

            var existingCartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == productId);

            if (existingCartItem == null)
                throw new ArgumentException("Product not found in cart");

            if (quantity <= 0)
            {
                // Remove the item if quantity <= 0
                _context.CartItems.Remove(existingCartItem);
            }
            else
            {
                // Update Quantity and UpdatedAt
                existingCartItem.Quantity = quantity;
                existingCartItem.UpdatedAt = DateTime.Now;
            }

            await _context.SaveChangesAsync();
            
            return await GetByUserIdAsync(userId) ?? cart;
        }

        public async Task<CartResponse> RemoveItemFromCartAsync(int userId, int productId)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                throw new ArgumentException("No active cart found for user");

            var existingCartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == productId);

            if (existingCartItem == null)
                throw new ArgumentException("Product not found in cart");

            // Remove the CartItem
            _context.CartItems.Remove(existingCartItem);
            await _context.SaveChangesAsync();
            
            return await GetByUserIdAsync(userId) ?? cart;
        }

        public async Task<CartResponse> ClearCartAsync(int userId)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                throw new ArgumentException("No cart found for user");

            // Remove all cart items in a single operation
            var cartItems = await _context.CartItems
                .Where(ci => ci.CartId == cart.Id)
                .ToListAsync();

            if (cartItems.Any())
            {
                _context.CartItems.RemoveRange(cartItems);
                await _context.SaveChangesAsync();
            }
            
            // Ensure cart remains active even when empty
            var cartEntity = await _context.Carts.FindAsync(cart.Id);
            if (cartEntity != null && !cartEntity.IsActive)
            {
                cartEntity.IsActive = true;
                cartEntity.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();
            }
            
            return await GetByUserIdAsync(userId) ?? cart;
        }
    }
}
