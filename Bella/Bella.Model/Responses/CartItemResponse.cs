using System;

namespace Bella.Model.Responses
{
    public class CartItemResponse
    {
        public int Id { get; set; }
        public int Quantity { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int CartId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public decimal ProductPrice { get; set; }
        public byte[]? ProductPicture { get; set; }
        public decimal TotalPrice => ProductPrice * Quantity; // Calculated property
    }
}
