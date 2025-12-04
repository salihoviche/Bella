using System;

namespace Bella.Model.Responses
{
    public class AppointmentResponse
    {
        public int Id { get; set; }
        public decimal FinalPrice { get; set; }
        public DateTime AppointmentDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int HairdresserId { get; set; }
        public string HairdresserName { get; set; } = string.Empty;
        public int StatusId { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public int? HairstyleId { get; set; }
        public string? HairstyleName { get; set; }
        public decimal? HairstylePrice { get; set; }
        public byte[]? HairstyleImage { get; set; }
        public int? FacialHairId { get; set; }
        public string? FacialHairName { get; set; }
        public decimal? FacialHairPrice { get; set; }
        public byte[]? FacialHairImage { get; set; }
        public int? DyingId { get; set; }
        public string? DyingName { get; set; }
        public string? DyingHexCode { get; set; }
    }
}

