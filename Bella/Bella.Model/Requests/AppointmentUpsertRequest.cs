using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class AppointmentUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int HairdresserId { get; set; }

        // StatusId is automatically set to 1 (Reserved) on create
        // Can be updated via Cancel/Complete actions
        public int? StatusId { get; set; }

        [Required]
        public DateTime AppointmentDate { get; set; }

        public int? HairstyleId { get; set; }

        public int? FacialHairId { get; set; }

        public int? DyingId { get; set; }

        public bool IsActive { get; set; } = true;
    }
}

