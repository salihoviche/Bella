using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class AppointmentController : BaseCRUDController<AppointmentResponse, AppointmentSearchObject, AppointmentUpsertRequest, AppointmentUpsertRequest>
    {
        public AppointmentController(IAppointmentService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<AppointmentResponse>> Get([FromQuery] AppointmentSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<AppointmentResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost("{id}/cancel")]
        [AllowAnonymous]
        public async Task<AppointmentResponse> CancelAppointment(int id)
        {
            return await ((IAppointmentService)_crudService).CancelAppointmentAsync(id);
        }

        [HttpPost("{id}/complete")]
        [AllowAnonymous]
        public async Task<AppointmentResponse> CompleteAppointment(int id)
        {
            return await ((IAppointmentService)_crudService).CompleteAppointmentAsync(id);
        }
    }
}

