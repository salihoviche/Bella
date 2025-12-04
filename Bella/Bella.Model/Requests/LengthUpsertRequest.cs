using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class LengthUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        public byte[]? Image { get; set; }
    }
}

