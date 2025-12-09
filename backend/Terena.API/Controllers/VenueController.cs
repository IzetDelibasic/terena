using Microsoft.AspNetCore.Mvc;
using Terena.API.Controllers.BaseControllers;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.Interfaces;

namespace Terena.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class VenueController : BaseCRUDController<VenueDTO, VenueSearchObject, VenueUpsertRequest, VenueUpsertRequest>
{
    public VenueController(IVenueService service) : base(service)
    {
    }
}
