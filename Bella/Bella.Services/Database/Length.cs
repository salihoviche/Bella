using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Services.Database
{
    public class Length
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        public byte[]? Image { get; set; }
    }
}

