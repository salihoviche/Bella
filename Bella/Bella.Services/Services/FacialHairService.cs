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
    public class FacialHairService : BaseCRUDService<FacialHairResponse, FacialHairSearchObject, FacialHair, FacialHairUpsertRequest, FacialHairUpsertRequest>, IFacialHairService
    {
        public FacialHairService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<FacialHair> ApplyFilter(IQueryable<FacialHair> query, FacialHairSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(f => f.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(f => f.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(f => f.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(f => f.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(f => f.Name.Contains(search.FTS));
            }

            return query;
        }

        protected override async Task BeforeInsert(FacialHair entity, FacialHairUpsertRequest request)
        {
            if (await _context.FacialHairs.AnyAsync(f => f.Name == request.Name))
            {
                throw new InvalidOperationException("A facial hair style with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(FacialHair entity, FacialHairUpsertRequest request)
        {
            if (await _context.FacialHairs.AnyAsync(f => f.Name == request.Name && f.Id != entity.Id))
            {
                throw new InvalidOperationException("A facial hair style with this name already exists.");
            }
        }
    }
}

