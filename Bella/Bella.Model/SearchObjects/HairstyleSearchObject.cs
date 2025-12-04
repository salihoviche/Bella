namespace Bella.Model.SearchObjects
{
    public class HairstyleSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? IsActive { get; set; }
        public int? LengthId { get; set; }
        public int? GenderId { get; set; }
    }
}

