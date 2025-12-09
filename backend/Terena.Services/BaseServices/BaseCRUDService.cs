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
        TDbEntity entity;
        if (typeof(ISoftDeletable).IsAssignableFrom(typeof(TDbEntity)))
        {
            entity = set
                .Cast<ISoftDeletable>()
                .Where(e => !e.IsDeleted)
                .Cast<TDbEntity>()
                .FirstOrDefault(e => EF.Property<int>(e, "Id") == id);
        }
        else
        {
            entity = set.Find(id);
        }

        if (entity == null)
        {
            throw new Exception("Unable to find entity with the provided id!");
        }

        request.Adapt(entity);
        BeforeUpdate(request, entity);
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

        if (entity is ISoftDeletable softDeletableEntity && softDeletableEntity.IsDeleted)
        {
            throw new Exception("Entity is already deleted!");
        }

        BeforeDelete(id, entity);

        if (entity is ISoftDeletable softDeletableEntity2)
        {
            softDeletableEntity2.IsDeleted = true;
            softDeletableEntity2.DeleteTime = DateTime.Now;
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
