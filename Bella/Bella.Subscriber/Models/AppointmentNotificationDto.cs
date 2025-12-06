using System;

namespace Bella.Subscriber.Models
{
    public class AppointmentNotificationDto
    {
        public int AppointmentId { get; set; }
        public string HairdresserEmail { get; set; } = string.Empty;
        public string HairdresserName { get; set; } = string.Empty;
        public string UserFullName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string? UserPhoneNumber { get; set; }
        public DateTime AppointmentDate { get; set; }
        public decimal FinalPrice { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public string? HairstyleName { get; set; }
        public decimal? HairstylePrice { get; set; }
        public string? FacialHairName { get; set; }
        public decimal? FacialHairPrice { get; set; }
        public string? DyingName { get; set; }
        public string? DyingHexCode { get; set; }
    }
}

