using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;

namespace Bella.Services.Services
{
    public class CartItemService : BaseCRUDService<CartItemResponse, CartItemSearchObject, CartItem, CartItemUpsertRequest, CartItemUpsertRequest>, ICartItemService
    {
        public CartItemService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override CartItemResponse MapToResponse(CartItem entity)
        {
            return new CartItemResponse
            {
                Id = entity.Id,
                Quantity = entity.Quantity,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                CartId = entity.CartId,
                ProductId = entity.ProductId,
                ProductName = entity.Product?.Name ?? string.Empty,
                ProductPrice = entity.Product?.Price ?? 0,
                ProductPicture = entity.Product?.Picture
            };
        }

        protected override IQueryable<CartItem> ApplyFilter(IQueryable<CartItem> query, CartItemSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(ci => ci.Cart).Include(ci => ci.Product);

            if (search.CartId.HasValue)
            {
                query = query.Where(ci => ci.CartId == search.CartId.Value);
            }

            if (search.ProductId.HasValue)
            {
                query = query.Where(ci => ci.ProductId == search.ProductId.Value);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(ci => ci.Cart.UserId == search.UserId.Value);
            }

            if (search.MinQuantity.HasValue)
            {
                query = query.Where(ci => ci.Quantity >= search.MinQuantity.Value);
            }

            if (search.MaxQuantity.HasValue)
            {
                query = query.Where(ci => ci.Quantity <= search.MaxQuantity.Value);
            }

            return query;
        }

        public override async Task<CartItemResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<CartItem>()
                .Include(ci => ci.Cart)
                .Include(ci => ci.Product)
                .FirstOrDefaultAsync(ci => ci.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(CartItem entity, CartItemUpsertRequest request)
        {
            // Verify cart exists
            var cartExists = await _context.Carts.AnyAsync(c => c.Id == request.CartId);
            if (!cartExists)
            {
                throw new InvalidOperationException("The specified cart does not exist.");
            }

            // Verify product exists
            var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId);
            if (!productExists)
            {
                throw new InvalidOperationException("The specified product does not exist.");
            }

            // Check if item already exists in cart
            var existingItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == request.CartId && ci.ProductId == request.ProductId);

            if (existingItem != null)
            {
                throw new InvalidOperationException("This product is already in the cart. Use update quantity instead.");
            }

            entity.CreatedAt = DateTime.Now;
        }

        protected override async Task BeforeUpdate(CartItem entity, CartItemUpsertRequest request)
        {
            // Verify cart exists
            var cartExists = await _context.Carts.AnyAsync(c => c.Id == request.CartId);
            if (!cartExists)
            {
                throw new InvalidOperationException("The specified cart does not exist.");
            }

            // Verify product exists
            var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId);
            if (!productExists)
            {
                throw new InvalidOperationException("The specified product does not exist.");
            }

            entity.UpdatedAt = DateTime.Now;
        }
    }
}
