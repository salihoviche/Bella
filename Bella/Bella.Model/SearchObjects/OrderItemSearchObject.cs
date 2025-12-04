namespace Bella.Model.SearchObjects
{
    public class OrderItemSearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public int? ProductId { get; set; }
        public int? UserId { get; set; }
        public int? MinQuantity { get; set; }
        public int? MaxQuantity { get; set; }
        public decimal? MinUnitPrice { get; set; }
        public decimal? MaxUnitPrice { get; set; }
    }
}
