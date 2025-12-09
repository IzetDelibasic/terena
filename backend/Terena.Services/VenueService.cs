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
        entity.Amenities = new List<VenueAmenity>();
        if (request.Amenities != null)
            entity.Amenities.AddRange(request.Amenities.Select(a => new VenueAmenity { Name = a, IsAvailable = true }));

        entity.OperatingHours = new List<OperatingHour>();
        if (request.OperatingHours != null)
            entity.OperatingHours.AddRange(request.OperatingHours.Select(o => new OperatingHour { Day = o.Day, StartTime = o.StartTime, EndTime = o.EndTime }));

        entity.CancellationPolicy = request.CancellationPolicy != null ? new CancellationPolicy { FreeUntil = request.CancellationPolicy.FreeUntil, Fee = request.CancellationPolicy.Fee } : null;
        entity.Discount = request.Discount != null ? new Discount { Percentage = request.Discount.Percentage, ForBookings = request.Discount.ForBookings } : null;
    }

    public override void BeforeUpdate(VenueUpsertRequest request, Venue entity)
    {
        entity.Amenities = new List<VenueAmenity>();
        if (request.Amenities != null)
        {
            entity.Amenities.AddRange(request.Amenities.Select(a => new VenueAmenity { Name = a, IsAvailable = true }));
        }

        entity.OperatingHours = new List<OperatingHour>();
        if (request.OperatingHours != null)
        {
            entity.OperatingHours.AddRange(request.OperatingHours.Select(o => new OperatingHour { Day = o.Day, StartTime = o.StartTime, EndTime = o.EndTime }));
        }

        if (request.CancellationPolicy != null)
        {
            entity.CancellationPolicy = new CancellationPolicy
            {
                FreeUntil = request.CancellationPolicy.FreeUntil,
                Fee = request.CancellationPolicy.Fee
            };
        }
        else
        {
            entity.CancellationPolicy = null;
        }

        if (request.Discount != null)
        {
            entity.Discount = new Discount
            {
                Percentage = request.Discount.Percentage,
                ForBookings = request.Discount.ForBookings
            };
        }
        else
        {
            entity.Discount = null;
        }
    }
}
