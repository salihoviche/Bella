using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Services.Database
{
    public class FacialHair
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        public byte[]? Image { get; set; }
        
        [Required]
        public decimal Price { get; set; }
        
        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}

