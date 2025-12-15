using Microsoft.AspNetCore.Mvc;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services;
using Terena.API.Controllers.BaseControllers;

namespace Terena.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewController : BaseCRUDController<ReviewDTO, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        private readonly ReviewService _reviewService;

        public ReviewController(ReviewService service) : base(service)
        {
            _reviewService = service;
        }

        [HttpGet("venue/{venueId}/average-rating")]
        public async Task<ActionResult<decimal>> GetVenueAverageRating(int venueId)
        {
            var rating = await _reviewService.GetVenueAverageRatingAsync(venueId);
            return Ok(rating);
        }

        [HttpGet("venue/{venueId}/total-reviews")]
        public async Task<ActionResult<int>> GetVenueTotalReviews(int venueId)
        {
            var total = await _reviewService.GetVenueTotalReviewsAsync(venueId);
            return Ok(total);
        }
    }
}
