using Terena.Models.DTOs;

namespace Terena.Services.Interfaces;

public interface IRecommendationService
{
    Task<List<VenueDTO>> GetRecommendedVenuesAsync(int userId, int count = 10);
}
