using System;

namespace Bella.Model.SearchObjects
{
    public class AppointmentSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? HairdresserId { get; set; }
        public int? StatusId { get; set; }
        public int? HairstyleId { get; set; }
        public int? FacialHairId { get; set; }
        public int? DyingId { get; set; }
        public bool? IsActive { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public DateTime? AppointmentDateFrom { get; set; }
        public DateTime? AppointmentDateTo { get; set; }
        public DateTime? AppointmentDate { get; set; }
    }
}

