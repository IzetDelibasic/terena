using Mapster;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;
using Terena.Models.HelperClasses;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;
using Terena.Services.Database;
using PagedResult = Terena.Models.HelperClasses.PagedResult<object>;

namespace Terena.Services.BaseServices;

public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> 
    where TSearch : BaseSearchObject 
    where TDbEntity : class 
    where TModel : class
{
    public TerenaDbContext Context { get; set; }

    protected BaseService(TerenaDbContext context)
    {
        Context = context;
    }

    public virtual Terena.Models.HelperClasses.PagedResult<TModel> GetPaged(TSearch search)
    {
        var query = Context.Set<TDbEntity>().AsQueryable();

        if (!string.IsNullOrEmpty(search?.IncludeTables))
        {
            query = ApplyIncludes(query, search.IncludeTables);
        }

        query = AddFilter(search, query);

        int count = query.Count();

        if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
        {
            query = ApplySorting(query, search.OrderBy, search.SortDirection);
        }

        if (search?.Page.HasValue == true && search.PageSize.HasValue == true)
        {
            query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
        }

        var list = query.ToList();
        var result = list.Adapt<List<TModel>>();

        return new Terena.Models.HelperClasses.PagedResult<TModel>
        {
            ResultList = result,
            Count = count
        };
    }

    public virtual TModel GetById(int id)
    {
        var entity = Context.Set<TDbEntity>().Find(id);
        return entity != null ? entity.Adapt<TModel>() : null;
    }

    public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
    {
        return query;
    }

    private IQueryable<TDbEntity> ApplyIncludes(IQueryable<TDbEntity> query, string includes)
    {
        try
        {
            var tableIncludes = includes.Split(',');
            query = tableIncludes.Aggregate(query, (current, inc) => current.Include(inc));
        }
        catch (Exception)
        {
            throw new Exception("Invalid include list!");
        }

        return query;
    }

    private IQueryable<TDbEntity> ApplySorting(IQueryable<TDbEntity> query, string orderBy, string sortDirection)
    {
        try
        {
            query = query.OrderBy($"{orderBy} {sortDirection}");
        }
        catch (Exception)
        {
            throw new Exception("Invalid sorting!");
        }

        return query;
    }
}
