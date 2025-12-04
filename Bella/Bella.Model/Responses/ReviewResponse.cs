using System;

namespace Bella.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserFullName { get; set; } = string.Empty;
        public string HairdresserFullName { get; set; } = string.Empty;
        public int AppointmentId { get; set; }
        public AppointmentResponse? Appointment { get; set; }
    }
}

