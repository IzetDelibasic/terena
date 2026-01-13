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
            .Include(v => v.CancellationPolicy)
            .Include(v => v.Discount)
            .FirstOrDefault(v => v.Id == id);

        if (entity == null)
            return null;

        return entity.Adapt<VenueDTO>();
    }

    public override VenueDTO Update(int id, VenueUpsertRequest request)
    {
        var entity = Context.Set<Venue>()
            .Include(v => v.CancellationPolicy)
            .Include(v => v.Discount)
            .FirstOrDefault(v => v.Id == id);

        if (entity == null)
        {
            throw new Exception("Unable to find venue with the provided id!");
        }

        request.Adapt(entity);
        BeforeUpdate(request, entity);
        Context.SaveChanges();

        AfterUpdate(request, entity);

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
        MapAmenitiesFromList(request, entity);
        MapCancellationPolicyAndDiscount(request, entity);
    }

    public override void BeforeUpdate(VenueUpsertRequest request, Venue entity)
    {
        MapAmenitiesFromList(request, entity);
        MapCancellationPolicyAndDiscount(request, entity);
    }
    
    private void MapCancellationPolicyAndDiscount(VenueUpsertRequest request, Venue entity)
    {
        if (request.CancellationPolicy != null)
        {
            if (entity.CancellationPolicy == null)
            {
                entity.CancellationPolicy = new CancellationPolicy
                {
                    FreeUntil = request.CancellationPolicy.FreeUntil,
                    Fee = request.CancellationPolicy.Fee
                };
            }
            else
            {
                entity.CancellationPolicy.FreeUntil = request.CancellationPolicy.FreeUntil;
                entity.CancellationPolicy.Fee = request.CancellationPolicy.Fee;
            }
        }

        if (request.Discount != null)
        {
            if (entity.Discount == null)
            {
                entity.Discount = new Discount
                {
                    Percentage = request.Discount.Percentage,
                    ForBookings = request.Discount.ForBookings
                };
            }
            else
            {
                entity.Discount.Percentage = request.Discount.Percentage;
                entity.Discount.ForBookings = request.Discount.ForBookings;
            }
        }
    }
    
    private void MapAmenitiesFromList(VenueUpsertRequest request, Venue entity)
    {
        if (request.Amenities != null && request.Amenities.Any())
        {
            entity.HasParking = request.Amenities.Contains("Parking");
            entity.HasShowers = request.Amenities.Contains("Showers");
            entity.HasLighting = request.Amenities.Contains("Lighting");
            entity.HasChangingRooms = request.Amenities.Contains("Restrooms");
            entity.HasEquipmentRental = request.Amenities.Contains("WiFi");
            entity.HasCafeBar = request.Amenities.Contains("CCTV");
            entity.HasWaterFountain = request.Amenities.Contains("Water Fountain");
            entity.HasSeatingArea = request.Amenities.Contains("Seating Area");
        }
        else
        {
            entity.HasParking = request.HasParking;
            entity.HasShowers = request.HasShowers;
            entity.HasLighting = request.HasLighting;
            entity.HasChangingRooms = request.HasChangingRooms;
            entity.HasEquipmentRental = request.HasEquipmentRental;
            entity.HasCafeBar = request.HasCafeBar;
            entity.HasWaterFountain = request.HasWaterFountain;
            entity.HasSeatingArea = request.HasSeatingArea;
        }
    }
}
