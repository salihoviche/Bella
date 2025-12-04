using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class StatusUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;
    }
}

