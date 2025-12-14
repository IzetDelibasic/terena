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
        }
    }
}
