using Terena.Models.HelperClasses;
using Terena.Models.SearchObjects;

namespace Terena.Services.BaseInterfaces;

public interface IService<TModel, TSearch> where TSearch : BaseSearchObject
{
    Task<PagedResult<TModel>> GetPagedAsync(TSearch search);
    TModel GetById(int id);
}
