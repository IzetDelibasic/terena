using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Terena.API.Controllers.BaseControllers;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services;
using Terena.Services.Interfaces;

namespace Terena.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingController : BaseCRUDController<BookingDTO, BookingSearchObject, BookingInsertRequest, BookingUpdateRequest>
    {
        private readonly IBookingService _bookingService;
        private readonly PaymentService _paymentService;

        public BookingController(IBookingService service, PaymentService paymentService) : base(service)
        {
            _bookingService = service;
            _paymentService = paymentService;
        }

        [HttpPost("create-payment-intent")]
        public async Task<ActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request)
        {
            try
            {
                var paymentIntent = await _paymentService.CreatePaymentIntentAsync(
                    request.Amount,
                    "eur",
                    request.Description
                );

                return Ok(new
                {
                    clientSecret = paymentIntent.ClientSecret,
                    paymentIntentId = paymentIntent.Id
                });
            }
            catch (Stripe.StripeException ex)
            {
                return BadRequest(new
                {
                    error = "Stripe error",
                    message = ex.Message,
                    code = ex.StripeError?.Code
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = "Internal server error",
                    message = ex.Message
                });
            }
        }

        [HttpPost("{id}/confirm")]
        public async Task<ActionResult<BookingDTO>> ConfirmBooking(int id)
        {
            var result = await _bookingService.ConfirmBookingAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/cancel")]
        public async Task<ActionResult<BookingDTO>> CancelBooking(int id, [FromBody] CancelBookingRequest request)
        {
            var result = await _bookingService.CancelBookingAsync(id, request.CancellationReason);
            return Ok(result);
        }

        [HttpPost("{id}/complete")]
        public async Task<ActionResult<BookingDTO>> CompleteBooking(int id)
        {
            var result = await _bookingService.CompleteBookingAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/payment")]
        public async Task<ActionResult<BookingDTO>> ProcessPayment(int id, [FromBody] ProcessPaymentRequest request)
        {
            var result = await _bookingService.ProcessPaymentAsync(id, request.TransactionId);
            return Ok(result);
        }

        [HttpPost("{id}/refund")]
        public async Task<ActionResult<BookingDTO>> RefundBooking(int id, [FromBody] RefundBookingRequest request)
        {
            var result = await _bookingService.RefundBookingAsync(id, request.RefundAmount);
            return Ok(result);
        }

        [HttpGet("available-slots")]
        public async Task<ActionResult<List<string>>> GetAvailableTimeSlots([FromQuery] int venueId, [FromQuery] DateTime date, [FromQuery] int? courtId = null)
        {
            var slots = await _bookingService.GetAvailableTimeSlotsAsync(venueId, date, courtId);
            return Ok(slots);
        }

        [HttpGet("max-duration")]
        public async Task<ActionResult<int>> GetMaxDurationForSlot([FromQuery] int venueId, [FromQuery] DateTime date, [FromQuery] string timeSlot, [FromQuery] int? courtId = null)
        {
            var maxDuration = await _bookingService.GetMaxDurationForSlotAsync(venueId, date, timeSlot, courtId);
            return Ok(maxDuration);
        }

        [HttpGet("admin/all")]
        public async Task<ActionResult> GetAllBookingsForAdmin([FromQuery] BookingSearchObject search)
        {
            var result = await _bookingService.GetPagedAsync(search);
            return Ok(result);
        }

        [HttpPost("{id}/admin/confirm")]
        public async Task<ActionResult<BookingDTO>> AdminConfirmBooking(int id)
        {
            try
            {
                var result = await _bookingService.ConfirmBookingAsync(id);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("{id}/admin/reject")]
        public async Task<ActionResult<BookingDTO>> AdminRejectBooking(int id, [FromBody] CancelBookingRequest request)
        {
            try
            {
                var result = await _bookingService.CancelBookingAsync(id, request.CancellationReason ?? "Rejected by admin");
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
