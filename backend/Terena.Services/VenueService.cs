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
            var term = search.SearchTerm.ToLower();
            query = query.Where(x =>
                x.Name.ToLower().Contains(term) ||
                x.Location.ToLower().Contains(term) ||
                x.Address.ToLower().Contains(term));
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
        entity.Amenities = request.Amenities?.Select(a => new VenueAmenity { Name = a, IsAvailable = true }).ToList();
        entity.OperatingHours = request.OperatingHours?.Select(o => new OperatingHour { Day = o.Day, StartTime = o.StartTime, EndTime = o.EndTime }).ToList();
        entity.CancellationPolicy = request.CancellationPolicy != null ? new CancellationPolicy { FreeUntil = request.CancellationPolicy.FreeUntil, Fee = request.CancellationPolicy.Fee } : null;
        entity.Discount = request.Discount != null ? new Discount { Percentage = request.Discount.Percentage, ForBookings = request.Discount.ForBookings } : null;
    }
}
