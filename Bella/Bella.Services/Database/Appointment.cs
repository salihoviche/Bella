using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Services.Database
{
    public class Appointment
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public decimal FinalPrice { get; set; }
        
        [Required]
        public DateTime AppointmentDate { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public bool IsActive { get; set; } = true;

        // Foreign keys
        [Required]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [Required]
        public int HairdresserId { get; set; }
        public virtual User Hairdresser { get; set; } = null!;

        [Required]
        public int StatusId { get; set; }
        public virtual Status Status { get; set; } = null!;

        // Optional service foreign keys
        public int? HairstyleId { get; set; }
        public virtual Hairstyle? Hairstyle { get; set; }

        public int? FacialHairId { get; set; }
        public virtual FacialHair? FacialHair { get; set; }

        public int? DyingId { get; set; }
        public virtual Dying? Dying { get; set; }
    }
}

