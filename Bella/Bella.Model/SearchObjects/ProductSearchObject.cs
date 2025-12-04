namespace Bella.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? IsActive { get; set; }
        public int? CategoryId { get; set; }
        public int? ManufacturerId { get; set; }
    }
}
