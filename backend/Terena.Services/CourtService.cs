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

        public override async Task<Terena.Models.HelperClasses.PagedResult<CourtDTO>> GetPagedAsync(CourtSearchObject search)
        {
            var query = Context.Set<Court>().Include(c => c.Venue).AsQueryable();

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
            var result = list.Adapt<List<CourtDTO>>();

            return new Terena.Models.HelperClasses.PagedResult<CourtDTO>
            {
                ResultList = result,
                Count = count
            };
        }

        public override CourtDTO GetById(int id)
        {
            var entity = Context.Set<Court>().Include(c => c.Venue).FirstOrDefault(c => c.Id == id);
            return entity?.Adapt<CourtDTO>();
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
