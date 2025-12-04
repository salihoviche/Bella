namespace Bella.Model.Responses
{
    public class CartSummaryResponse
    {
        public int UserId { get; set; }
        public int? CartId { get; set; }
        public int TotalItems { get; set; }
        public decimal TotalAmount { get; set; }
    }
}
