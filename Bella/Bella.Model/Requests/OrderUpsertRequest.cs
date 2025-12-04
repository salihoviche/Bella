using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class OrderUpsertRequest
    {
        [Required]
        public decimal TotalAmount { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
