using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class OrderItemUpsertRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Required]
        public decimal UnitPrice { get; set; }
        
        [Required]
        public decimal TotalPrice { get; set; }
        
        [Required]
        public int OrderId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
    }
}
