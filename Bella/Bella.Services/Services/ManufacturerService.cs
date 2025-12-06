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
    public class ManufacturerService : BaseCRUDService<ManufacturerResponse, ManufacturerSearchObject, Manufacturer, ManufacturerUpsertRequest, ManufacturerUpsertRequest>, IManufacturerService
    {
        public ManufacturerService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Manufacturer> ApplyFilter(IQueryable<Manufacturer> query, ManufacturerSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(m => m.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(m => m.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(m => m.Name.Contains(search.FTS) || (m.Description != null && m.Description.Contains(search.FTS)));
            }

            return query;
        }

        protected override async Task BeforeInsert(Manufacturer entity, ManufacturerUpsertRequest request)
        {
            if (await _context.Manufacturers.AnyAsync(m => m.Name == request.Name))
            {
                throw new InvalidOperationException("A manufacturer with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Manufacturer entity, ManufacturerUpsertRequest request)
        {
            if (await _context.Manufacturers.AnyAsync(m => m.Name == request.Name && m.Id != entity.Id))
            {
                throw new InvalidOperationException("A manufacturer with this name already exists.");
            }
        }
    }
}

