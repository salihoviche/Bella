using Bella.Model.Responses;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Bella.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;
        private readonly IHairdresserAnalyticsService _hairdresserAnalyticsService;

        public AnalyticsController(IAnalyticsService analyticsService, IHairdresserAnalyticsService hairdresserAnalyticsService)
        {
            _analyticsService = analyticsService;
            _hairdresserAnalyticsService = hairdresserAnalyticsService;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<AnalyticsResponse> Get()
        {
            return await _analyticsService.GetAnalyticsAsync();
        }

        [HttpGet("hairdresser/{hairdresserId}/{year}/{month}")]
        [AllowAnonymous]
        public async Task<HairdresserAnalyticsResponse> GetHairdresserAnalytics(int hairdresserId, int year, int month)
        {
            return await _hairdresserAnalyticsService.GetHairdresserAnalyticsAsync(hairdresserId, year, month);
        }
    }
}

