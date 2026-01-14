using Terena.Models.SearchObjects;

namespace Terena.Services.BaseInterfaces;

public interface ICRUDService<TModel, TSearch, TInsert, TUpdate> : IService<TModel, TSearch>
    where TModel : class
    where TSearch : BaseSearchObject
{
    TModel Insert(TInsert request);
    TModel Update(int id, TUpdate request);
    TModel Delete(int id);
}
