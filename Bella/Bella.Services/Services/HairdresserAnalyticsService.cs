using Bella.Model.Responses;
using Bella.Services.Database;
using Bella.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Bella.Services.Services
{
    public class HairdresserAnalyticsService : IHairdresserAnalyticsService
    {
        private readonly BellaDbContext _context;

        public HairdresserAnalyticsService(BellaDbContext context)
        {
            _context = context;
        }

        public async Task<HairdresserAnalyticsResponse> GetHairdresserAnalyticsAsync(int hairdresserId, int year, int month)
        {
            // Validate month and year
            if (month < 1 || month > 12)
            {
                throw new ArgumentException("Month must be between 1 and 12.", nameof(month));
            }

            if (year < 2000 || year > 2100)
            {
                throw new ArgumentException("Year must be a valid year.", nameof(year));
            }

            // Get first and last day of the month
            var startDate = new DateTime(year, month, 1);
            var endDate = startDate.AddMonths(1).AddDays(-1);

            // Get all appointments for the hairdresser in the specified month
            var appointments = await _context.Appointments
                .Where(a => a.HairdresserId == hairdresserId 
                    && a.AppointmentDate >= startDate 
                    && a.AppointmentDate < startDate.AddMonths(1)
                    && a.IsActive)
                .ToListAsync();

            // Group by day and calculate statistics
            var dailyData = appointments
                .GroupBy(a => a.AppointmentDate.Date)
                .Select(g => new DailyAnalyticsData
                {
                    Date = g.Key,
                    DayNumber = g.Key.Day,
                    AppointmentCount = g.Count(),
                    Revenue = g.Sum(a => a.FinalPrice)
                })
                .OrderBy(d => d.Date)
                .ToList();

            // Create a complete list for all days in the month (including days with no appointments)
            var allDaysInMonth = new List<DailyAnalyticsData>();
            for (int day = 1; day <= DateTime.DaysInMonth(year, month); day++)
            {
                var currentDate = new DateTime(year, month, day);
                var existingData = dailyData.FirstOrDefault(d => d.Date == currentDate);
                
                if (existingData != null)
                {
                    allDaysInMonth.Add(existingData);
                }
                else
                {
                    allDaysInMonth.Add(new DailyAnalyticsData
                    {
                        Date = currentDate,
                        DayNumber = day,
                        AppointmentCount = 0,
                        Revenue = 0
                    });
                }
            }

            // Calculate totals
            var totalAppointments = appointments.Count;
            var totalRevenue = appointments.Sum(a => a.FinalPrice);

            return new HairdresserAnalyticsResponse
            {
                HairdresserId = hairdresserId,
                Year = year,
                Month = month,
                TotalAppointments = totalAppointments,
                TotalRevenue = totalRevenue,
                DailyData = allDaysInMonth
            };
        }
    }
}

