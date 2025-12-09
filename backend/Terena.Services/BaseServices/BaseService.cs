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

    public virtual async Task<Terena.Models.HelperClasses.PagedResult<TModel>> GetPagedAsync(TSearch search)
    {
        var query = Context.Set<TDbEntity>().AsQueryable();

        if (!string.IsNullOrEmpty(search?.IncludeTables))
        {
            query = ApplyIncludes(query, search.IncludeTables);
        }

        query = AddFilter(search, query);

        int count = await query.CountAsync();

        if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
        {
            query = ApplySorting(query, search.OrderBy, search.SortDirection);
        }

        if ((search?.Page.HasValue ?? false) && (search?.PageSize.HasValue ?? false))
        {
            query = query.Skip((search.Page!.Value - 1) * search.PageSize!.Value).Take(search.PageSize.Value);
        }

        var list = await query.ToListAsync();
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
        if (entity != null)
        {
            var softDeletable = entity as ISoftDeletable;
            if (softDeletable != null && softDeletable.IsDeleted)
            {
                return null;
            }
            return entity.Adapt<TModel>();
        }
        return null;
    }

    public virtual TModel GetById(int id, string includeTables = null)
    {
        TDbEntity entity;
        if (!string.IsNullOrEmpty(includeTables))
        {
            var query = Context.Set<TDbEntity>().AsQueryable();
            query = ApplyIncludes(query, includeTables);
            entity = query.FirstOrDefault(e => EF.Property<int>(e, "Id") == id);
        }
        else
        {
            entity = Context.Set<TDbEntity>().Find(id);
        }
        return entity != null ? entity.Adapt<TModel>() : null;
    }

    public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
    {
        return query;
    }

    private IQueryable<TDbEntity> ApplyIncludes(IQueryable<TDbEntity> query, string includes)
    {
        var allowedIncludes = new HashSet<string>(new[] {
            "Amenities",
            "OperatingHours",
            "CancellationPolicy",
            "Discount"
        }, StringComparer.OrdinalIgnoreCase);
        try
        {
            var tableIncludes = includes.Split(',');
            foreach (var inc in tableIncludes)
            {
                var trimmedInc = inc.Trim();
                if (!allowedIncludes.Contains(trimmedInc))
                {
                    throw new Exception($"Include path '{trimmedInc}' is not allowed.");
                }
                query = query.Include(trimmedInc);
            }
        }
        catch (Exception ex)
        {
            throw new Exception("Invalid include list!", ex);
        }

        return query;
    }

    private IQueryable<TDbEntity> ApplySorting(IQueryable<TDbEntity> query, string orderBy, string sortDirection)
    {
        var validProperties = typeof(TDbEntity).GetProperties().Select(p => p.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
        if (!validProperties.Contains(orderBy))
        {
            throw new Exception($"Invalid OrderBy column: {orderBy}");
        }
        var validDirections = new[] { "asc", "desc" };
        if (!validDirections.Contains(sortDirection?.ToLowerInvariant()))
        {
            throw new Exception($"Invalid SortDirection: {sortDirection}");
        }

        try
        {
            query = query.OrderBy($"{orderBy} {sortDirection}");
        }
        catch (Exception ex)
        {
            throw new Exception("Invalid sorting!", ex);
        }

        return query;
    }
}
