using System;
using System.Collections.Generic;

namespace Bella.Model.Responses
{
    public class HairdresserAnalyticsResponse
    {
        public int HairdresserId { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public int TotalAppointments { get; set; }
        public decimal TotalRevenue { get; set; }
        public List<DailyAnalyticsData> DailyData { get; set; } = new List<DailyAnalyticsData>();
    }

    public class DailyAnalyticsData
    {
        public DateTime Date { get; set; }
        public int DayNumber { get; set; }
        public int AppointmentCount { get; set; }
        public decimal Revenue { get; set; }
    }
}

