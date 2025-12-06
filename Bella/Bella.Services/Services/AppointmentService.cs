using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Database;
using Bella.Services.Interfaces;
using Bella.Subscriber.Models;
using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Bella.Services.Services
{
    public class AppointmentService : BaseCRUDService<AppointmentResponse, AppointmentSearchObject, Appointment, AppointmentUpsertRequest, AppointmentUpsertRequest>, IAppointmentService
    {
        private const decimal DyingPrice = 10m;

        public AppointmentService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Appointment> ApplyFilter(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            query = query
                .Include(a => a.User)
                .Include(a => a.Hairdresser)
                .Include(a => a.Status)
                .Include(a => a.Hairstyle)
                .Include(a => a.FacialHair)
                .Include(a => a.Dying);

            if (search.UserId.HasValue)
            {
                query = query.Where(a => a.UserId == search.UserId.Value);
            }

            if (search.HairdresserId.HasValue)
            {
                query = query.Where(a => a.HairdresserId == search.HairdresserId.Value);
            }

            if (search.HairstyleId.HasValue)
            {
                query = query.Where(a => a.HairstyleId == search.HairstyleId.Value);
            }

            if (search.FacialHairId.HasValue)
            {
                query = query.Where(a => a.FacialHairId == search.FacialHairId.Value);
            }

            if (search.DyingId.HasValue)
            {
                query = query.Where(a => a.DyingId == search.DyingId.Value);
            }

            if (search.StatusId.HasValue)
            {
                query = query.Where(a => a.StatusId == search.StatusId.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(a => a.IsActive == search.IsActive.Value);
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(a => a.FinalPrice >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(a => a.FinalPrice <= search.MaxPrice.Value);
            }

            if (search.AppointmentDateFrom.HasValue)
            {
                query = query.Where(a => a.AppointmentDate >= search.AppointmentDateFrom.Value);
            }

            if (search.AppointmentDateTo.HasValue)
            {
                query = query.Where(a => a.AppointmentDate <= search.AppointmentDateTo.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a => 
                    a.User.FirstName.Contains(search.FTS) || 
                    a.User.LastName.Contains(search.FTS) ||
                    a.Hairdresser.FirstName.Contains(search.FTS) ||
                    a.Hairdresser.LastName.Contains(search.FTS));
            }

            return query;
        }

        public override async Task<AppointmentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Appointments
                .Include(a => a.User)
                .Include(a => a.Hairdresser)
                .Include(a => a.Status)
                .Include(a => a.Hairstyle)
                .Include(a => a.FacialHair)
                .Include(a => a.Dying)
                .FirstOrDefaultAsync(a => a.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override AppointmentResponse MapToResponse(Appointment entity)
        {
            var response = new AppointmentResponse
            {
                Id = entity.Id,
                FinalPrice = entity.FinalPrice,
                AppointmentDate = entity.AppointmentDate,
                CreatedAt = entity.CreatedAt,
                IsActive = entity.IsActive,
                UserId = entity.UserId,
                UserName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(),
                HairdresserId = entity.HairdresserId,
                HairdresserName = $"{entity.Hairdresser?.FirstName} {entity.Hairdresser?.LastName}".Trim(),
                StatusId = entity.StatusId,
                StatusName = entity.Status?.Name ?? string.Empty,
                HairstyleId = entity.HairstyleId,
                HairstyleName = entity.Hairstyle?.Name,
                HairstylePrice = entity.Hairstyle?.Price,
                HairstyleImage = entity.Hairstyle?.Image,
                FacialHairId = entity.FacialHairId,
                FacialHairName = entity.FacialHair?.Name,
                FacialHairPrice = entity.FacialHair?.Price,
                FacialHairImage = entity.FacialHair?.Image,
                DyingId = entity.DyingId,
                DyingName = entity.Dying?.Name,
                DyingHexCode = entity.Dying?.HexCode
            };

            return response;
        }

        protected override async Task BeforeInsert(Appointment entity, AppointmentUpsertRequest request)
        {
            // Automatically set status to Reserved (Id = 1) on create
            entity.StatusId = 1;

            // Calculate final price
            entity.FinalPrice = await CalculateFinalPriceAsync(request.HairstyleId, request.FacialHairId, request.DyingId);

            // Validate that at least one service is selected
            if (!request.HairstyleId.HasValue && !request.FacialHairId.HasValue && !request.DyingId.HasValue)
            {
                throw new InvalidOperationException("At least one service (Hairstyle, FacialHair, or Dying) must be selected.");
            }

            // Validate user exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User not found.");
            }

            // Validate hairdresser exists and has hairdresser role
            var hairdresser = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == request.HairdresserId);

            if (hairdresser == null)
            {
                throw new InvalidOperationException("Hairdresser not found.");
            }

            if (!hairdresser.UserRoles.Any(ur => ur.Role.Name == "Hairdresser"))
            {
                throw new InvalidOperationException("Selected user is not a hairdresser.");
            }
        }

        protected override async Task AfterInsert(Appointment entity, AppointmentUpsertRequest request)
        {
            await SendAppointmentNotificationAsync(entity.Id);
        }

        private async Task SendAppointmentNotificationAsync(int appointmentId)
        {
            try
            {
                var appointment = await _context.Appointments
                    .Include(a => a.User)
                    .Include(a => a.Hairdresser)
                    .Include(a => a.Status)
                    .Include(a => a.Hairstyle)
                    .Include(a => a.FacialHair)
                    .Include(a => a.Dying)
                    .FirstOrDefaultAsync(a => a.Id == appointmentId);

                if (appointment == null || string.IsNullOrWhiteSpace(appointment.Hairdresser?.Email))
                {
                    return;
                }

                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

                using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                var notification = new AppointmentNotification
                {
                    Appointment = new AppointmentNotificationDto
                    {
                        AppointmentId = appointment.Id,
                        HairdresserEmail = appointment.Hairdresser.Email,
                        HairdresserName = $"{appointment.Hairdresser.FirstName} {appointment.Hairdresser.LastName}".Trim(),
                        UserFullName = $"{appointment.User.FirstName} {appointment.User.LastName}".Trim(),
                        UserEmail = appointment.User.Email,
                        UserPhoneNumber = appointment.User.PhoneNumber,
                        AppointmentDate = appointment.AppointmentDate,
                        FinalPrice = appointment.FinalPrice,
                        StatusName = appointment.Status?.Name ?? string.Empty,
                        HairstyleName = appointment.Hairstyle?.Name,
                        HairstylePrice = appointment.Hairstyle?.Price,
                        FacialHairName = appointment.FacialHair?.Name,
                        FacialHairPrice = appointment.FacialHair?.Price,
                        DyingName = appointment.Dying?.Name,
                        DyingHexCode = appointment.Dying?.HexCode
                    }
                };

                await bus.PubSub.PublishAsync(notification);
            }
            catch (Exception ex)
            {
                // Log error but don't throw - appointment creation should succeed even if notification fails
                Console.WriteLine($"Failed to send appointment notification: {ex.Message}");
            }
        }

        private async Task SendAppointmentCancellationNotificationAsync(int appointmentId)
        {
            try
            {
                var appointment = await _context.Appointments
                    .Include(a => a.User)
                    .Include(a => a.Hairdresser)
                    .Include(a => a.Status)
                    .Include(a => a.Hairstyle)
                    .Include(a => a.FacialHair)
                    .Include(a => a.Dying)
                    .FirstOrDefaultAsync(a => a.Id == appointmentId);

                if (appointment == null || string.IsNullOrWhiteSpace(appointment.Hairdresser?.Email))
                {
                    return;
                }

                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

                using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                var notification = new AppointmentCancellationNotification
                {
                    Appointment = new AppointmentNotificationDto
                    {
                        AppointmentId = appointment.Id,
                        HairdresserEmail = appointment.Hairdresser.Email,
                        HairdresserName = $"{appointment.Hairdresser.FirstName} {appointment.Hairdresser.LastName}".Trim(),
                        UserFullName = $"{appointment.User.FirstName} {appointment.User.LastName}".Trim(),
                        UserEmail = appointment.User.Email,
                        UserPhoneNumber = appointment.User.PhoneNumber,
                        AppointmentDate = appointment.AppointmentDate,
                        FinalPrice = appointment.FinalPrice,
                        StatusName = appointment.Status?.Name ?? string.Empty,
                        HairstyleName = appointment.Hairstyle?.Name,
                        HairstylePrice = appointment.Hairstyle?.Price,
                        FacialHairName = appointment.FacialHair?.Name,
                        FacialHairPrice = appointment.FacialHair?.Price,
                        DyingName = appointment.Dying?.Name,
                        DyingHexCode = appointment.Dying?.HexCode
                    }
                };

                await bus.PubSub.PublishAsync(notification);
            }
            catch (Exception ex)
            {
                // Log error but don't throw - appointment cancellation should succeed even if notification fails
                Console.WriteLine($"Failed to send appointment cancellation notification: {ex.Message}");
            }
        }

        protected override async Task BeforeUpdate(Appointment entity, AppointmentUpsertRequest request)
        {
            // If StatusId is provided in request, use it; otherwise keep existing status
            if (request.StatusId.HasValue)
            {
                entity.StatusId = request.StatusId.Value;
            }

            // Calculate final price
            entity.FinalPrice = await CalculateFinalPriceAsync(request.HairstyleId, request.FacialHairId, request.DyingId);

            // Validate that at least one service is selected
            if (!request.HairstyleId.HasValue && !request.FacialHairId.HasValue && !request.DyingId.HasValue)
            {
                throw new InvalidOperationException("At least one service (Hairstyle, FacialHair, or Dying) must be selected.");
            }

            // Validate user exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User not found.");
            }

            // Validate hairdresser exists and has hairdresser role
            var hairdresser = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == request.HairdresserId);

            if (hairdresser == null)
            {
                throw new InvalidOperationException("Hairdresser not found.");
            }

            if (!hairdresser.UserRoles.Any(ur => ur.Role.Name == "Hairdresser"))
            {
                throw new InvalidOperationException("Selected user is not a hairdresser.");
            }
        }

        public async Task<AppointmentResponse> CancelAppointmentAsync(int id)
        {
            var appointment = await _context.Appointments
                .Include(a => a.User)
                .Include(a => a.Hairdresser)
                .Include(a => a.Status)
                .Include(a => a.Hairstyle)
                .Include(a => a.FacialHair)
                .Include(a => a.Dying)
                .FirstOrDefaultAsync(a => a.Id == id);
            
            if (appointment == null)
            {
                throw new InvalidOperationException("Appointment not found.");
            }

            if (!appointment.IsActive)
            {
                throw new InvalidOperationException("Cannot cancel an inactive appointment.");
            }

            // Set status to Cancelled (Id = 2)
            appointment.StatusId = 2;
            
            await _context.SaveChangesAsync();

            // Send cancellation notification
            await SendAppointmentCancellationNotificationAsync(id);

            return await GetByIdAsync(id) ?? throw new InvalidOperationException("Failed to retrieve updated appointment.");
        }

        public async Task<AppointmentResponse> CompleteAppointmentAsync(int id)
        {
            var appointment = await _context.Appointments.FindAsync(id);
            
            if (appointment == null)
            {
                throw new InvalidOperationException("Appointment not found.");
            }

            if (!appointment.IsActive)
            {
                throw new InvalidOperationException("Cannot complete an inactive appointment.");
            }

            // Set status to Completed (Id = 3)
            appointment.StatusId = 3;
            
            await _context.SaveChangesAsync();

            return await GetByIdAsync(id) ?? throw new InvalidOperationException("Failed to retrieve updated appointment.");
        }

        private async Task<decimal> CalculateFinalPriceAsync(int? hairstyleId, int? facialHairId, int? dyingId)
        {
            decimal totalPrice = 0;

            if (hairstyleId.HasValue)
            {
                var hairstyle = await _context.Hairstyles.FindAsync(hairstyleId.Value);
                if (hairstyle != null)
                {
                    totalPrice += hairstyle.Price;
                }
            }

            if (facialHairId.HasValue)
            {
                var facialHair = await _context.FacialHairs.FindAsync(facialHairId.Value);
                if (facialHair != null)
                {
                    totalPrice += facialHair.Price;
                }
            }

            if (dyingId.HasValue)
            {
                // Dying is always +10, regardless of which dye is selected
                totalPrice += DyingPrice;
            }

            return totalPrice;
        }
    }
}

