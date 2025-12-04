using System.Collections.Generic;

namespace Bella.Model.Responses
{
    public class AnalyticsResponse
    {
        public List<TopProductAnalyticsResponse> Top3Products { get; set; } = new List<TopProductAnalyticsResponse>();
        public List<TopHairstyleAnalyticsResponse> Top3Hairstyles { get; set; } = new List<TopHairstyleAnalyticsResponse>();
        public List<TopFacialHairAnalyticsResponse> Top3FacialHairs { get; set; } = new List<TopFacialHairAnalyticsResponse>();
        public List<TopDyingAnalyticsResponse> Top3DyingColors { get; set; } = new List<TopDyingAnalyticsResponse>();
    }

    public class TopProductAnalyticsResponse
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public byte[]? ProductImage { get; set; }
        public int TotalQuantitySold { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class TopHairstyleAnalyticsResponse
    {
        public int HairstyleId { get; set; }
        public string HairstyleName { get; set; } = string.Empty;
        public byte[]? HairstyleImage { get; set; }
        public int TotalAppointments { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class TopFacialHairAnalyticsResponse
    {
        public int FacialHairId { get; set; }
        public string FacialHairName { get; set; } = string.Empty;
        public byte[]? FacialHairImage { get; set; }
        public int TotalAppointments { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class TopDyingAnalyticsResponse
    {
        public int DyingId { get; set; }
        public string DyingName { get; set; } = string.Empty;
        public string? DyingHexCode { get; set; }
        public int TotalAppointments { get; set; }
        public decimal TotalRevenue { get; set; }
    }
}

