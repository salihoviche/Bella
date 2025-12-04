using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Services.Database
{
    public class Dying
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(7)]
        public string? HexCode { get; set; }
        
        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}

