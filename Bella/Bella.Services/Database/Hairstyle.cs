using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Services.Database
{
    public class Hairstyle
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

        [Required]
        public int LengthId { get; set; }
        public virtual Length Length { get; set; } = null!;

        [Required]
        public int GenderId { get; set; }
        public virtual Gender Gender { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}

