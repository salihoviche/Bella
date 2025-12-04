using System;
using System.ComponentModel.DataAnnotations;

namespace Bella.Services.Database
{
    public class OrderItem
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Required]
        public decimal UnitPrice { get; set; } // Price at time of purchase
        
        [Required]
        public decimal TotalPrice { get; set; } // UnitPrice * Quantity
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Foreign keys
        [Required]
        public int OrderId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
        
        // Navigation properties
        public virtual Order Order { get; set; } = null!;
        public virtual Product Product { get; set; } = null!;
    }
}
