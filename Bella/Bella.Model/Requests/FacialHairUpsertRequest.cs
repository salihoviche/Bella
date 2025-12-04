using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class FacialHairUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        public byte[]? Image { get; set; }
        
        [Required]
        [Range(0.01, 999.99, ErrorMessage = "Price must be between 0.01 and 999.99")]
        public decimal Price { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}

