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
    public class StatusService : BaseCRUDService<StatusResponse, StatusSearchObject, Status, StatusUpsertRequest, StatusUpsertRequest>, IStatusService
    {
        public StatusService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Status> ApplyFilter(IQueryable<Status> query, StatusSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(s => s.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(s => s.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(s => s.Name.Contains(search.FTS));
            }

            return query;
        }

        protected override async Task BeforeInsert(Status entity, StatusUpsertRequest request)
        {
            if (await _context.Statuses.AnyAsync(s => s.Name == request.Name))
            {
                throw new InvalidOperationException("A status with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Status entity, StatusUpsertRequest request)
        {
            if (await _context.Statuses.AnyAsync(s => s.Name == request.Name && s.Id != entity.Id))
            {
                throw new InvalidOperationException("A status with this name already exists.");
            }
        }
    }
}

