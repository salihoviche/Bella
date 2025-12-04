using System;
using System.Collections.Generic;
using System.Linq;

namespace Bella.Model.Responses
{
    public class CartResponse
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public bool IsActive { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public List<CartItemResponse> CartItems { get; set; } = new List<CartItemResponse>();
        public int TotalItems => CartItems.Sum(ci => ci.Quantity); // Calculated property
        public decimal TotalAmount => CartItems.Sum(ci => ci.TotalPrice); // Calculated property
    }
}
