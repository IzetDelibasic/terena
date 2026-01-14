using Microsoft.AspNetCore.Mvc;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;

namespace Terena.API.Controllers.BaseControllers;

[Route("api/[controller]")]
[ApiController]
public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> : BaseController<TModel, TSearch> 
    where TSearch : BaseSearchObject 
    where TModel : class
{
    protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;

    public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
    {
        _service = service;
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    public virtual TModel Insert(TInsert request)
    {
        return _service.Insert(request);
    }

    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public virtual TModel Update(int id, TUpdate request)
    {
        return _service.Update(id, request);
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public virtual TModel Delete(int id)
    {
        return _service.Delete(id);
    }
}
