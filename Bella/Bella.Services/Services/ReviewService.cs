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
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>, IReviewService
    {
        public ReviewService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = query
                .Include(r => r.User)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Hairdresser)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.User)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Status)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Hairstyle)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.FacialHair)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Dying);

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.HairdresserId.HasValue)
            {
                query = query.Where(r => r.Appointment != null && r.Appointment.HairdresserId == search.HairdresserId.Value);
            }

            if (search.AppointmentId.HasValue)
            {
                query = query.Where(r => r.AppointmentId == search.AppointmentId.Value);
            }

            if (search.Rating.HasValue)
            {
                query = query.Where(r => r.Rating == search.Rating.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(r => r.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(r => 
                    (r.Comment != null && r.Comment.Contains(search.FTS)) ||
                    r.User.FirstName.Contains(search.FTS) ||
                    r.User.LastName.Contains(search.FTS));
            }

            return query;
        }

        public override async Task<ReviewResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Hairdresser)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.User)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Status)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Hairstyle)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.FacialHair)
                .Include(r => r.Appointment)
                    .ThenInclude(a => a.Dying)
                .FirstOrDefaultAsync(r => r.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            var userFullName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim();
            var hairdresserFullName = entity.Appointment?.Hairdresser != null
                ? $"{entity.Appointment.Hairdresser.FirstName} {entity.Appointment.Hairdresser.LastName}".Trim()
                : string.Empty;

            var appointmentResponse = entity.Appointment != null
                ? new AppointmentResponse
                {
                    Id = entity.Appointment.Id,
                    FinalPrice = entity.Appointment.FinalPrice,
                    AppointmentDate = entity.Appointment.AppointmentDate,
                    CreatedAt = entity.Appointment.CreatedAt,
                    IsActive = entity.Appointment.IsActive,
                    UserId = entity.Appointment.UserId,
                    UserName = $"{entity.Appointment.User?.FirstName} {entity.Appointment.User?.LastName}".Trim(),
                    HairdresserId = entity.Appointment.HairdresserId,
                    HairdresserName = hairdresserFullName,
                    StatusId = entity.Appointment.StatusId,
                    StatusName = entity.Appointment.Status?.Name ?? string.Empty,
                    HairstyleId = entity.Appointment.HairstyleId,
                    HairstyleName = entity.Appointment.Hairstyle?.Name,
                    HairstylePrice = entity.Appointment.Hairstyle?.Price,
                    HairstyleImage = entity.Appointment.Hairstyle?.Image,
                    FacialHairId = entity.Appointment.FacialHairId,
                    FacialHairName = entity.Appointment.FacialHair?.Name,
                    FacialHairPrice = entity.Appointment.FacialHair?.Price,
                    FacialHairImage = entity.Appointment.FacialHair?.Image,
                    DyingId = entity.Appointment.DyingId,
                    DyingName = entity.Appointment.Dying?.Name,
                    DyingHexCode = entity.Appointment.Dying?.HexCode
                }
                : null;

            var response = new ReviewResponse
            {
                Id = entity.Id,
                Rating = entity.Rating,
                Comment = entity.Comment,
                CreatedAt = entity.CreatedAt,
                IsActive = entity.IsActive,
                UserId = entity.UserId,
                UserName = userFullName,
                UserFullName = userFullName,
                HairdresserFullName = hairdresserFullName,
                AppointmentId = entity.AppointmentId,
                Appointment = appointmentResponse
            };

            return response;
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            // Validate user exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User not found.");
            }

            // Validate appointment exists
            if (!await _context.Appointments.AnyAsync(a => a.Id == request.AppointmentId))
            {
                throw new InvalidOperationException("Appointment not found.");
            }

            // Check if user already reviewed this appointment
            if (await _context.Reviews.AnyAsync(r => r.UserId == request.UserId && r.AppointmentId == request.AppointmentId))
            {
                throw new InvalidOperationException("User has already reviewed this appointment.");
            }
        }

        protected override async Task BeforeUpdate(Review entity, ReviewUpsertRequest request)
        {
            // Validate user exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User not found.");
            }

            // Validate appointment exists
            if (!await _context.Appointments.AnyAsync(a => a.Id == request.AppointmentId))
            {
                throw new InvalidOperationException("Appointment not found.");
            }

            // Check if another review exists for this user and appointment (excluding current review)
            if (await _context.Reviews.AnyAsync(r => r.UserId == request.UserId && r.AppointmentId == request.AppointmentId && r.Id != entity.Id))
            {
                throw new InvalidOperationException("User has already reviewed this appointment.");
            }
        }
    }
}

