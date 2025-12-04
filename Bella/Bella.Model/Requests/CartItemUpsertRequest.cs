using System.ComponentModel.DataAnnotations;

namespace Bella.Model.Requests
{
    public class CartItemUpsertRequest
    {
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1")]
        public int Quantity { get; set; }
        
        [Required]
        public int CartId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
    }
}
