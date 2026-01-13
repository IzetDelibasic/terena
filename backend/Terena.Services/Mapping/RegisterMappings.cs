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
                    ? (decimal?)src.Reviews.Average(r => r.Rating) 
                    : null)
                .Map(dest => dest.TotalReviews, src => src.Reviews != null ? src.Reviews.Count : 0)
                .Map(dest => dest.Amenities, src => GetAmenitiesFromBooleans(src))
                .Map(dest => dest.HasParking, src => src.HasParking)
                .Map(dest => dest.HasShowers, src => src.HasShowers)
                .Map(dest => dest.HasLighting, src => src.HasLighting)
                .Map(dest => dest.HasChangingRooms, src => src.HasChangingRooms)
                .Map(dest => dest.HasEquipmentRental, src => src.HasEquipmentRental)
                .Map(dest => dest.HasCafeBar, src => src.HasCafeBar)
                .Map(dest => dest.HasWaterFountain, src => src.HasWaterFountain)
                .Map(dest => dest.HasSeatingArea, src => src.HasSeatingArea)
                .Map(dest => dest.OperatingHours, src => src.OperatingHours != null 
                    ? src.OperatingHours.Select(oh => new OperatingHourDTO 
                    { 
                        Day = oh.Day, 
                        StartTime = oh.StartTime, 
                        EndTime = oh.EndTime 
                    }).ToList() 
                    : new List<OperatingHourDTO>())
                .Map(dest => dest.CancellationPolicy, src => src.CancellationPolicy != null 
                    ? new CancellationPolicyDTO 
                    { 
                        FreeUntil = src.CancellationPolicy.FreeUntil, 
                        Fee = src.CancellationPolicy.Fee 
                    } 
                    : null)
                .Map(dest => dest.Discount, src => src.Discount != null 
                    ? new DiscountDTO 
                    { 
                        Percentage = src.Discount.Percentage, 
                        ForBookings = src.Discount.ForBookings 
                    } 
                    : null);
        }

        private static List<string> GetAmenitiesFromBooleans(Venue venue)
        {
            var amenities = new List<string>();
            if (venue.HasParking) amenities.Add("Parking");
            if (venue.HasShowers) amenities.Add("Showers");
            if (venue.HasLighting) amenities.Add("Lighting");
            if (venue.HasChangingRooms) amenities.Add("Restrooms");
            if (venue.HasEquipmentRental) amenities.Add("WiFi");
            if (venue.HasCafeBar) amenities.Add("CCTV");
            if (venue.HasWaterFountain) amenities.Add("Water Fountain");
            if (venue.HasSeatingArea) amenities.Add("Seating Area");
            return amenities;
        }
    }
}
