using Microsoft.AspNetCore.Mvc;
using Terena.Services.Interfaces;

namespace Terena.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class RecommendationController : ControllerBase
{
    private readonly IRecommendationService _recommendationService;

    public RecommendationController(IRecommendationService recommendationService)
    {
        _recommendationService = recommendationService;
    }

    [HttpGet("GetRecommendations/{userId}")]
    public async Task<IActionResult> GetRecommendations(int userId, [FromQuery] int count = 10)
    {
        try
        {
            var recommendations = await _recommendationService.GetRecommendedVenuesAsync(userId, count);
            return Ok(recommendations);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
