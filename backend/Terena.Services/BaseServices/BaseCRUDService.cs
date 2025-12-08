using Mapster;
using Terena.Models.SearchObjects;
using Terena.Services.BaseInterfaces;
using Terena.Services.Database;

namespace Terena.Services.BaseServices;

public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity>, ICRUDService<TModel, TSearch, TInsert, TUpdate> 
    where TModel : class 
    where TSearch : BaseSearchObject 
    where TDbEntity : class
{
    protected BaseCRUDService(TerenaDbContext context) : base(context)
    {
    }

    public virtual TModel Insert(TInsert request)
    {
        TDbEntity entity = request.Adapt<TDbEntity>();

        BeforeInsert(request, entity);

        Context.Add(entity);
        Context.SaveChanges();
        
        AfterInsert(request, entity);

        return entity.Adapt<TModel>();
    }

    public virtual TModel Update(int id, TUpdate request)
    {
        var set = Context.Set<TDbEntity>();
        var entity = set.Find(id);
        
        if (entity == null)
        {
            throw new Exception("Unable to find entity with the provided id!");
        }

        BeforeUpdate(request, entity);
        
        request.Adapt(entity);
        Context.SaveChanges();

        AfterUpdate(request, entity);

        return entity.Adapt<TModel>();
    }

    public virtual void Delete(int id)
    {
        var entity = Context.Set<TDbEntity>().Find(id);

        if (entity == null)
        {
            throw new Exception("Unable to find entity with the provided id!");
        }

        BeforeDelete(id, entity);

        if (entity is ISoftDeletable softDeletableEntity)
        {
            softDeletableEntity.IsDeleted = true;
            softDeletableEntity.VrijemeBrisanja = DateTime.Now;
            Context.Update(entity);
        }
        else
        {
            Context.Remove(entity);
        }

        Context.SaveChanges();

        AfterDelete(id, entity);
    }

    public virtual void BeforeInsert(TInsert request, TDbEntity entity) { }
    public virtual void AfterInsert(TInsert request, TDbEntity entity) { }
    public virtual void BeforeUpdate(TUpdate request, TDbEntity entity) { }
    public virtual void AfterUpdate(TUpdate request, TDbEntity entity) { }
    public virtual void BeforeDelete(int id, TDbEntity entity) { }
    public virtual void AfterDelete(int id, TDbEntity entity) { }
}
