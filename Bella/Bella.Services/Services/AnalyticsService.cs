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
    public class AnalyticsService : IAnalyticsService
    {
        private readonly BellaDbContext _context;
        private const decimal DyingPrice = 10m;

        public AnalyticsService(BellaDbContext context)
        {
            _context = context;
        }

        public async Task<AnalyticsResponse> GetAnalyticsAsync()
        {
            var response = new AnalyticsResponse
            {
                Top3Products = await GetTop3ProductsAsync(),
                Top3Hairstyles = await GetTop3HairstylesAsync(),
                Top3FacialHairs = await GetTop3FacialHairsAsync(),
                Top3DyingColors = await GetTop3DyingColorsAsync(),
            };

            return response;
        }

        private async Task<List<TopProductAnalyticsResponse>> GetTop3ProductsAsync()
        {
            var topProducts = await _context.OrderItems
                .Include(oi => oi.Order)
                .Include(oi => oi.Product)
                .Where(oi => oi.Order.IsActive)
                .GroupBy(oi => new { oi.ProductId, oi.Product.Name, oi.Product.Picture })
                .Select(g => new
                {
                    ProductId = g.Key.ProductId,
                    ProductName = g.Key.Name,
                    ProductImage = g.Key.Picture,
                    TotalQuantitySold = g.Sum(oi => oi.Quantity),
                    TotalRevenue = g.Sum(oi => oi.TotalPrice)
                })
                .OrderByDescending(x => x.TotalQuantitySold)
                .Take(3)
                .ToListAsync();

            return topProducts.Select(p => new TopProductAnalyticsResponse
            {
                ProductId = p.ProductId,
                ProductName = p.ProductName,
                ProductImage = p.ProductImage,
                TotalQuantitySold = p.TotalQuantitySold,
                TotalRevenue = p.TotalRevenue
            }).ToList();
        }

        private async Task<List<TopHairstyleAnalyticsResponse>> GetTop3HairstylesAsync()
        {
            var topHairstyles = await _context.Appointments
                .Include(a => a.Hairstyle)
                .Where(a => a.IsActive && a.HairstyleId.HasValue)
                .GroupBy(a => new { a.HairstyleId, a.Hairstyle!.Name, a.Hairstyle.Image, a.Hairstyle.Price })
                .Select(g => new
                {
                    HairstyleId = g.Key.HairstyleId!.Value,
                    HairstyleName = g.Key.Name,
                    HairstyleImage = g.Key.Image,
                    TotalAppointments = g.Count(),
                    TotalRevenue = g.Sum(a => g.Key.Price)
                })
                .OrderByDescending(x => x.TotalAppointments)
                .Take(3)
                .ToListAsync();

            return topHairstyles.Select(h => new TopHairstyleAnalyticsResponse
            {
                HairstyleId = h.HairstyleId,
                HairstyleName = h.HairstyleName,
                HairstyleImage = h.HairstyleImage,
                TotalAppointments = h.TotalAppointments,
                TotalRevenue = h.TotalRevenue
            }).ToList();
        }

        private async Task<List<TopFacialHairAnalyticsResponse>> GetTop3FacialHairsAsync()
        {
            var topFacialHairs = await _context.Appointments
                .Include(a => a.FacialHair)
                .Where(a => a.IsActive && a.FacialHairId.HasValue)
                .GroupBy(a => new { a.FacialHairId, a.FacialHair!.Name, a.FacialHair.Image, a.FacialHair.Price })
                .Select(g => new
                {
                    FacialHairId = g.Key.FacialHairId!.Value,
                    FacialHairName = g.Key.Name,
                    FacialHairImage = g.Key.Image,
                    TotalAppointments = g.Count(),
                    TotalRevenue = g.Sum(a => g.Key.Price)
                })
                .OrderByDescending(x => x.TotalAppointments)
                .Take(3)
                .ToListAsync();

            return topFacialHairs.Select(f => new TopFacialHairAnalyticsResponse
            {
                FacialHairId = f.FacialHairId,
                FacialHairName = f.FacialHairName,
                FacialHairImage = f.FacialHairImage,
                TotalAppointments = f.TotalAppointments,
                TotalRevenue = f.TotalRevenue
            }).ToList();
        }

        private async Task<List<TopDyingAnalyticsResponse>> GetTop3DyingColorsAsync()
        {
            var topDyingColors = await _context.Appointments
                .Include(a => a.Dying)
                .Where(a => a.IsActive && a.DyingId.HasValue)
                .GroupBy(a => new { a.DyingId, a.Dying!.Name, a.Dying.HexCode })
                .Select(g => new
                {
                    DyingId = g.Key.DyingId!.Value,
                    DyingName = g.Key.Name,
                    DyingHexCode = g.Key.HexCode,
                    TotalAppointments = g.Count(),
                    TotalRevenue = g.Count() * DyingPrice
                })
                .OrderByDescending(x => x.TotalAppointments)
                .Take(3)
                .ToListAsync();

            return topDyingColors.Select(d => new TopDyingAnalyticsResponse
            {
                DyingId = d.DyingId,
                DyingName = d.DyingName,
                DyingHexCode = d.DyingHexCode,
                TotalAppointments = d.TotalAppointments,
                TotalRevenue = d.TotalRevenue
            }).ToList();
        }
    }
}

