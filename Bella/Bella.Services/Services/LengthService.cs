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
    public class LengthService : BaseCRUDService<LengthResponse, LengthSearchObject, Length, LengthUpsertRequest, LengthUpsertRequest>, ILengthService
    {
        public LengthService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Length> ApplyFilter(IQueryable<Length> query, LengthSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(x => x.Name.Contains(search.FTS));
            }

            return query;
        }

        protected override async Task BeforeInsert(Length entity, LengthUpsertRequest request)
        {
            if (await _context.Lengths.AnyAsync(l => l.Name == request.Name))
            {
                throw new InvalidOperationException("A length with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Length entity, LengthUpsertRequest request)
        {
            if (await _context.Lengths.AnyAsync(l => l.Name == request.Name && l.Id != entity.Id))
            {
                throw new InvalidOperationException("A length with this name already exists.");
            }
        }
    }
}

