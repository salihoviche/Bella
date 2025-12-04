namespace Bella.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? HairdresserId { get; set; }
        public int? AppointmentId { get; set; }
        public int? Rating { get; set; }
        public bool? IsActive { get; set; }
    }
}

