using Bella.Model.Responses;
using System.Threading.Tasks;

namespace Bella.Services.Interfaces
{
    public interface IHairdresserAnalyticsService
    {
        Task<HairdresserAnalyticsResponse> GetHairdresserAnalyticsAsync(int hairdresserId, int year, int month);
    }
}

