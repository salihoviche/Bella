using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;

namespace Bella.Services.Interfaces
{
    public interface IAppointmentService : ICRUDService<AppointmentResponse, AppointmentSearchObject, AppointmentUpsertRequest, AppointmentUpsertRequest>
    {
        Task<AppointmentResponse> CancelAppointmentAsync(int id);
        Task<AppointmentResponse> CompleteAppointmentAsync(int id);
    }
}

