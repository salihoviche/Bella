namespace Bella.Model.SearchObjects
{
    public class CartItemSearchObject : BaseSearchObject
    {
        public int? CartId { get; set; }
        public int? ProductId { get; set; }
        public int? UserId { get; set; }
        public int? MinQuantity { get; set; }
        public int? MaxQuantity { get; set; }
    }
}
