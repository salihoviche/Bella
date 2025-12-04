using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class DyingUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(7)]
        [RegularExpression(@"^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$", ErrorMessage = "Hex code must be in format #RRGGBB or #RGB")]
        public string? HexCode { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}

