using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Terena.API.Controllers.BaseControllers;
using Terena.Models.DTOs;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.Interfaces;

namespace Terena.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingController : BaseCRUDController<BookingDTO, BookingSearchObject, BookingInsertRequest, BookingUpdateRequest>
    {
        private readonly IBookingService _bookingService;

        public BookingController(IBookingService service) : base(service)
        {
            _bookingService = service;
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
    }
}
