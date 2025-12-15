using System.Linq;
using Terena.Services.Database;

namespace Terena.Services.Helpers
{
    public static class VenueRatingHelper
    {
        public static (decimal? average, int total) CalculateVenueRatingAndCount(Venue venue)
        {
            if (venue?.Reviews == null || !venue.Reviews.Any())
                return (null, 0);
            return (venue.Reviews.Average(r => r.Rating), venue.Reviews.Count);
        }
    }
}
