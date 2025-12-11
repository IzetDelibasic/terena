using Microsoft.EntityFrameworkCore;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseServices;
using Terena.Services.Database;
using Terena.Services.Interfaces;

namespace Terena.Services
{
    public class CourtService : BaseCRUDService<CourtDTO, CourtSearchObject, Court, CourtInsertRequest, CourtUpdateRequest>, ICourtService
    {
        public CourtService(TerenaDbContext context) : base(context)
        {
        }

        public override IQueryable<Court> AddFilter(CourtSearchObject search, IQueryable<Court> query)
        {
            if (search.VenueId.HasValue)
            {
                query = query.Where(c => c.VenueId == search.VenueId.Value);
            }

            if (!string.IsNullOrEmpty(search.CourtType))
            {
                query = query.Where(c => c.CourtType.ToLower().Contains(search.CourtType.ToLower()));
            }

            if (search.IsAvailable.HasValue)
            {
                query = query.Where(c => c.IsAvailable == search.IsAvailable.Value);
            }

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(c => c.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return query;
        }
    }
}
