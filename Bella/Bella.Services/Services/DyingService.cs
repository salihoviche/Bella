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
    public class DyingService : BaseCRUDService<DyingResponse, DyingSearchObject, Dying, DyingUpsertRequest, DyingUpsertRequest>, IDyingService
    {
        public DyingService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Dying> ApplyFilter(IQueryable<Dying> query, DyingSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(d => d.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.HexCode))
            {
                query = query.Where(d => d.HexCode != null && d.HexCode.Contains(search.HexCode));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(d => d.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(d => d.Name.Contains(search.FTS) || 
                    (d.HexCode != null && d.HexCode.Contains(search.FTS)));
            }

            return query;
        }

        protected override async Task BeforeInsert(Dying entity, DyingUpsertRequest request)
        {
            if (await _context.Dyings.AnyAsync(d => d.Name == request.Name))
            {
                throw new InvalidOperationException("A dye color with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Dying entity, DyingUpsertRequest request)
        {
            if (await _context.Dyings.AnyAsync(d => d.Name == request.Name && d.Id != entity.Id))
            {
                throw new InvalidOperationException("A dye color with this name already exists.");
            }
        }
    }
}

