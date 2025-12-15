using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.Database;
using Terena.Services.BaseServices;

namespace Terena.Services
{
    public class ReviewService : BaseCRUDService<ReviewDTO, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>
    {
        public ReviewService(TerenaDbContext context) : base(context)
        {
        }

        public override IQueryable<Review> AddFilter(ReviewSearchObject search, IQueryable<Review> query)
        {
            query = base.AddFilter(search, query);

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.VenueId.HasValue)
            {
                query = query.Where(r => r.VenueId == search.VenueId.Value);
            }

            if (search.BookingId.HasValue)
            {
                query = query.Where(r => r.BookingId == search.BookingId.Value);
            }

            if (search.MinRating.HasValue)
            {
                query = query.Where(r => r.Rating >= search.MinRating.Value);
            }

            if (search.MaxRating.HasValue)
            {
                query = query.Where(r => r.Rating <= search.MaxRating.Value);
            }

            return query.Include(r => r.User)
                       .Include(r => r.Venue)
                       .Include(r => r.Booking);
        }

        public override void BeforeInsert(ReviewInsertRequest request, Review entity)
        {
            entity.CreatedAt = DateTime.UtcNow;
        }

        public async Task<decimal> GetVenueAverageRatingAsync(int venueId)
        {
            var reviews = await Context.Set<Review>()
                .Where(r => r.VenueId == venueId)
                .ToListAsync();

            if (!reviews.Any())
                return 0;

            return (decimal)reviews.Average(r => r.Rating);
        }

        public async Task<int> GetVenueTotalReviewsAsync(int venueId)
        {
            return await Context.Set<Review>()
                .Where(r => r.VenueId == venueId)
                .CountAsync();
        }
    }
}
