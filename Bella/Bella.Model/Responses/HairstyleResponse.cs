using System;

namespace Bella.Model.Responses
{
    public class HairstyleResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public byte[]? Image { get; set; }
        public decimal Price { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int LengthId { get; set; }
        public string LengthName { get; set; } = string.Empty;
        public int GenderId { get; set; }
        public string GenderName { get; set; } = string.Empty;
    }
}

