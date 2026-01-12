using Microsoft.EntityFrameworkCore;
using Mapster;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseServices;
using Terena.Services.Database;
using Terena.Services.Interfaces;

namespace Terena.Services;

public class VenueService : BaseCRUDService<VenueDTO, VenueSearchObject, Venue, VenueUpsertRequest, VenueUpsertRequest>, IVenueService
{
    public VenueService(TerenaDbContext context) : base(context)
    {
        TypeAdapterConfig<VenueUpsertRequest, Venue>.NewConfig()
            .Ignore(dest => dest.Amenities)
            .Ignore(dest => dest.OperatingHours)
            .Ignore(dest => dest.CancellationPolicy)
            .Ignore(dest => dest.Discount);
    }

    public override async Task<Terena.Models.HelperClasses.PagedResult<VenueDTO>> GetPagedAsync(VenueSearchObject search)
    {
        var query = Context.Set<Venue>()
            .Include(v => v.Reviews)
            .AsQueryable();

        query = AddFilter(search, query);

        int count = await query.CountAsync();

        if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
        {
            query = ApplySorting(query, search.OrderBy, search.SortDirection);
        }

        if (search != null && search.Page.HasValue && search.PageSize.HasValue)
        {
            query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
        }

        var list = await query.ToListAsync();
        var result = list.Adapt<System.Collections.Generic.List<VenueDTO>>();

        return new Terena.Models.HelperClasses.PagedResult<VenueDTO>
        {
            ResultList = result,
            Count = count
        };
    }

    public override VenueDTO GetById(int id)
    {
        var entity = Context.Set<Venue>()
            .Include(v => v.Reviews)
            .FirstOrDefault(v => v.Id == id);

        if (entity == null)
            return null;

        return entity.Adapt<VenueDTO>();
    }

    public override IQueryable<Venue> AddFilter(VenueSearchObject search, IQueryable<Venue> query)
    {
        if (!string.IsNullOrEmpty(search?.SearchTerm))
        {
            var term = search.SearchTerm;
            query = query.Where(x =>
                EF.Functions.Like(x.Name, "%" + term + "%") ||
                EF.Functions.Like(x.Location, "%" + term + "%") ||
                EF.Functions.Like(x.Address, "%" + term + "%")
            );
        }

        if (!string.IsNullOrEmpty(search?.SportType))
            query = query.Where(x => x.SportType == search.SportType);
        
        if (!string.IsNullOrEmpty(search?.Location))
            query = query.Where(x => x.Location == search.Location);
        
        if (!string.IsNullOrEmpty(search?.SurfaceType))
            query = query.Where(x => x.SurfaceType == search.SurfaceType);
        
        if (search?.MinPrice.HasValue == true)
            query = query.Where(x => x.PricePerHour >= search.MinPrice.Value);
        
        if (search?.MaxPrice.HasValue == true)
            query = query.Where(x => x.PricePerHour <= search.MaxPrice.Value);

        return query;
    }

    public override void BeforeInsert(VenueUpsertRequest request, Venue entity)
    {
        entity.HasParking = request.HasParking;
        entity.HasShowers = request.HasShowers;
        entity.HasLighting = request.HasLighting;
        entity.HasChangingRooms = request.HasChangingRooms;
        entity.HasEquipmentRental = request.HasEquipmentRental;
        entity.HasCafeBar = request.HasCafeBar;
    }

    public override void BeforeUpdate(VenueUpsertRequest request, Venue entity)
    {
        entity.HasParking = request.HasParking;
        entity.HasShowers = request.HasShowers;
        entity.HasLighting = request.HasLighting;
        entity.HasChangingRooms = request.HasChangingRooms;
        entity.HasEquipmentRental = request.HasEquipmentRental;
        entity.HasCafeBar = request.HasCafeBar;
    }
}
