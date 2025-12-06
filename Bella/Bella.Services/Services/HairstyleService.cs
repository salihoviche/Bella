using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Database;
using Bella.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Bella.Services.Services
{
    public class HairstyleService : BaseCRUDService<HairstyleResponse, HairstyleSearchObject, Hairstyle, HairstyleUpsertRequest, HairstyleUpsertRequest>, IHairstyleService
    {
        public HairstyleService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Hairstyle> ApplyFilter(IQueryable<Hairstyle> query, HairstyleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(h => h.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(h => h.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(h => h.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(h => h.IsActive == search.IsActive.Value);
            }

            if (search.LengthId.HasValue)
            {
                query = query.Where(h => h.LengthId == search.LengthId.Value);
            }

            if (search.GenderId.HasValue)
            {
                query = query.Where(h => h.GenderId == search.GenderId.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(h => h.Name.Contains(search.FTS));
            }

            return query
                .Include(h => h.Length)
                .Include(h => h.Gender);
        }

        public override async Task<HairstyleResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Hairstyles
                .Include(h => h.Length)
                .Include(h => h.Gender)
                .FirstOrDefaultAsync(h => h.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override HairstyleResponse MapToResponse(Hairstyle entity)
        {
            var response = new HairstyleResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                Image = entity.Image,
                Price = entity.Price,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                LengthId = entity.LengthId,
                LengthName = entity.Length?.Name ?? string.Empty,
                GenderId = entity.GenderId,
                GenderName = entity.Gender?.Name ?? string.Empty
            };

            return response;
        }

   
    }
}

