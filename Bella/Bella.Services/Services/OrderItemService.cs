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
    public class OrderItemService : BaseCRUDService<OrderItemResponse, OrderItemSearchObject, OrderItem, OrderItemUpsertRequest, OrderItemUpsertRequest>, IOrderItemService
    {
        public OrderItemService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override OrderItemResponse MapToResponse(OrderItem entity)
        {
            return new OrderItemResponse
            {
                Id = entity.Id,
                Quantity = entity.Quantity,
                UnitPrice = entity.UnitPrice,
                TotalPrice = entity.TotalPrice,
                CreatedAt = entity.CreatedAt,
                OrderId = entity.OrderId,
                ProductId = entity.ProductId,
                ProductName = entity.Product?.Name ?? string.Empty,
                ProductPicture = entity.Product?.Picture
            };
        }

        protected override IQueryable<OrderItem> ApplyFilter(IQueryable<OrderItem> query, OrderItemSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(oi => oi.Order).Include(oi => oi.Product);

            if (search.OrderId.HasValue)
            {
                query = query.Where(oi => oi.OrderId == search.OrderId.Value);
            }

            if (search.ProductId.HasValue)
            {
                query = query.Where(oi => oi.ProductId == search.ProductId.Value);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(oi => oi.Order.UserId == search.UserId.Value);
            }

            if (search.MinQuantity.HasValue)
            {
                query = query.Where(oi => oi.Quantity >= search.MinQuantity.Value);
            }

            if (search.MaxQuantity.HasValue)
            {
                query = query.Where(oi => oi.Quantity <= search.MaxQuantity.Value);
            }

            if (search.MinUnitPrice.HasValue)
            {
                query = query.Where(oi => oi.UnitPrice >= search.MinUnitPrice.Value);
            }

            if (search.MaxUnitPrice.HasValue)
            {
                query = query.Where(oi => oi.UnitPrice <= search.MaxUnitPrice.Value);
            }

            return query;
        }

        public override async Task<OrderItemResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<OrderItem>()
                .Include(oi => oi.Order)
                .Include(oi => oi.Product)
                .FirstOrDefaultAsync(oi => oi.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(OrderItem entity, OrderItemUpsertRequest request)
        {
            // Verify order exists
            var orderExists = await _context.Orders.AnyAsync(o => o.Id == request.OrderId);
            if (!orderExists)
            {
                throw new InvalidOperationException("The specified order does not exist.");
            }

            // Verify product exists
            var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId);
            if (!productExists)
            {
                throw new InvalidOperationException("The specified product does not exist.");
            }

            entity.CreatedAt = DateTime.Now;
        }

        protected override async Task BeforeUpdate(OrderItem entity, OrderItemUpsertRequest request)
        {
            // Verify order exists
            var orderExists = await _context.Orders.AnyAsync(o => o.Id == request.OrderId);
            if (!orderExists)
            {
                throw new InvalidOperationException("The specified order does not exist.");
            }

            // Verify product exists
            var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId);
            if (!productExists)
            {
                throw new InvalidOperationException("The specified product does not exist.");
            }
        }
    }
}
