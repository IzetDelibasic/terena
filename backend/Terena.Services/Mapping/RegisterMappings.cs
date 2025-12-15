using Mapster;
using Terena.Models.DTOs;
using Terena.Services.Database;

namespace Terena.Services.Mapping
{
    public static class RegisterMappings
    {
        public static void Register()
        {
            TypeAdapterConfig<Court, CourtDTO>.NewConfig()
                .Map(dest => dest.VenueName, src => src.Venue != null ? src.Venue.Name : null);

            TypeAdapterConfig<Booking, BookingDTO>.NewConfig()
                .Map(dest => dest.UserName, src => src.User != null ? src.User.Username : null)
                .Map(dest => dest.UserEmail, src => src.User != null ? src.User.Email : null)
                .Map(dest => dest.VenueName, src => src.Venue != null ? src.Venue.Name : null)
                .Map(dest => dest.VenueLocation, src => src.Venue != null ? src.Venue.Location : null)
                .Map(dest => dest.VenueAddress, src => src.Venue != null ? src.Venue.Address : null)
                .Map(dest => dest.VenueContactPhone, src => src.Venue != null ? src.Venue.ContactPhone : null)
                .Map(dest => dest.VenueAverageRating, src => src.Venue != null && src.Venue.Reviews != null && src.Venue.Reviews.Any() 
                    ? (decimal)src.Venue.Reviews.Average(r => r.Rating) 
                    : 0m)
                .Map(dest => dest.VenueTotalReviews, src => src.Venue != null && src.Venue.Reviews != null 
                    ? src.Venue.Reviews.Count 
                    : 0)
                .Map(dest => dest.CourtName, src => src.Court != null ? src.Court.Name : null)
                .Map(dest => dest.CourtMaxCapacity, src => src.Court != null ? src.Court.MaxCapacity : null);

            TypeAdapterConfig<Review, ReviewDTO>.NewConfig()
                .Map(dest => dest.UserUsername, src => src.User != null ? src.User.Username : null)
                .Map(dest => dest.VenueName, src => src.Venue != null ? src.Venue.Name : null);

            TypeAdapterConfig<Venue, VenueDTO>.NewConfig()
                .Map(dest => dest.AverageRating, src => src.Reviews != null && src.Reviews.Any() 
                    ? (decimal)src.Reviews.Average(r => r.Rating) 
                    : 0m)
                .Map(dest => dest.TotalReviews, src => src.Reviews != null ? src.Reviews.Count : 0);
        }
    }
}
