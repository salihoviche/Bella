using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class HairstyleUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        public byte[]? Image { get; set; }
        
        [Required]
        [Range(0.01, 999.99, ErrorMessage = "Price must be between 0.01 and 999.99")]
        public decimal Price { get; set; }
        
        public bool IsActive { get; set; } = true;

        [Required]
        public int LengthId { get; set; }

        [Required]
        public int GenderId { get; set; }
    }
}

