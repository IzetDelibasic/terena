using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;

namespace Terena.Services.Interfaces;

public interface IVenueService : ICRUDService<VenueDTO, VenueSearchObject, VenueUpsertRequest, VenueUpsertRequest>
{
}
