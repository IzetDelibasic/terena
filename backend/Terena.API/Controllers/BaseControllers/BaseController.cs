using Microsoft.AspNetCore.Mvc;
using Terena.Models.HelperClasses;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;

namespace Terena.API.Controllers.BaseControllers;

[Route("api/[controller]")]
[ApiController]
public class BaseController<TModel, TSearch> : ControllerBase 
    where TSearch : BaseSearchObject
{
    private readonly IService<TModel, TSearch> _service;

    public BaseController(IService<TModel, TSearch> service)
    {
        _service = service;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public virtual async Task<PagedResult<TModel>> GetList([FromQuery] TSearch searchObject)
    {
        return await _service.GetPagedAsync(searchObject);
    }

    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public virtual TModel GetById(int id)
    {
        return _service.GetById(id);
    }
}
