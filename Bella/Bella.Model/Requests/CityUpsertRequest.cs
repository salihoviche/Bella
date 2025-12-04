using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class CityUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
    }
} 