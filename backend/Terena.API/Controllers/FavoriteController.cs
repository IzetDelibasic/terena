using Microsoft.AspNetCore.Mvc;
using Terena.Models.DTOs;
using Terena.Services;

namespace Terena.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FavoriteController : ControllerBase
    {
        private readonly FavoriteService _favoriteService;

        public FavoriteController(FavoriteService service)
        {
            _favoriteService = service;
        }

        [HttpPost]
        public async Task<ActionResult<FavoriteVenueDTO>> AddFavorite([FromBody] Models.Requests.FavoriteVenueInsertRequest request)
        {
            var result = await _favoriteService.AddFavoriteAsync(request.UserId, request.VenueId);
            return Ok(result);
        }

        [HttpDelete("user/{userId}/venue/{venueId}")]
        public async Task<ActionResult> RemoveFavorite(int userId, int venueId)
        {
            await _favoriteService.RemoveFavoriteAsync(userId, venueId);
            return Ok();
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<FavoriteVenueDTO>>> GetUserFavorites(int userId)
        {
            var favorites = await _favoriteService.GetUserFavoritesAsync(userId);
            return Ok(favorites);
        }

        [HttpGet("user/{userId}/venue/{venueId}/check")]
        public async Task<ActionResult<bool>> IsFavorite(int userId, int venueId)
        {
            var isFavorite = await _favoriteService.IsFavoriteAsync(userId, venueId);
            return Ok(isFavorite);
        }
    }
}
