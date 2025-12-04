using Bella.Model.Responses;
using System.Threading.Tasks;

namespace Bella.Services.Interfaces
{
    public interface IAnalyticsService
    {
        Task<AnalyticsResponse> GetAnalyticsAsync();
    }
}

