using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using Terena.Models.Enums;
using Terena.Services.Database;

namespace Terena.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatisticsController : ControllerBase
    {
        private readonly TerenaDbContext _context;

        public StatisticsController(TerenaDbContext context)
        {
            _context = context;
        }

        [HttpGet("earnings")]
        public async Task<ActionResult<StatisticsEarningsDTO>> GetEarnings([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var query = _context.Bookings.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(b => b.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(b => b.CreatedAt <= toDate.Value);

            var totalEarnings = await query
                .Where(b => b.PaymentStatus == PaymentStatus.Paid)
                .SumAsync(b => b.TotalPrice);

            var totalBookings = await query.CountAsync();
            var completedBookings = await query.CountAsync(b => b.Status == BookingStatus.Completed);
            var cancelledBookings = await query.CountAsync(b => b.Status == BookingStatus.Cancelled);

            var averagePerBooking = totalBookings > 0 ? totalEarnings / totalBookings : 0;

            var previousPeriodDays = toDate.HasValue && fromDate.HasValue 
                ? (toDate.Value - fromDate.Value).Days 
                : 30;

            var previousFromDate = fromDate?.AddDays(-previousPeriodDays) ?? DateTime.UtcNow.AddDays(-60);
            var previousToDate = fromDate ?? DateTime.UtcNow.AddDays(-30);

            var previousEarnings = await _context.Bookings
                .Where(b => b.CreatedAt >= previousFromDate && b.CreatedAt <= previousToDate)
                .Where(b => b.PaymentStatus == PaymentStatus.Paid)
                .SumAsync(b => b.TotalPrice);

            var earningsChange = previousEarnings > 0 
                ? ((totalEarnings - previousEarnings) / previousEarnings) * 100 
                : 0;

            var previousBookings = await _context.Bookings
                .Where(b => b.CreatedAt >= previousFromDate && b.CreatedAt <= previousToDate)
                .CountAsync();

            var bookingsChange = previousBookings > 0 
                ? ((decimal)(totalBookings - previousBookings) / previousBookings) * 100 
                : 0;

            return Ok(new StatisticsEarningsDTO
            {
                TotalEarnings = totalEarnings,
                EarningsChangePercent = earningsChange,
                TotalBookings = totalBookings,
                BookingsChangePercent = bookingsChange,
                AveragePerBooking = averagePerBooking,
                CompletedBookings = completedBookings,
                CancelledBookings = cancelledBookings
            });
        }

        [HttpGet("weekly-earnings")]
        public async Task<ActionResult<WeeklyEarningsDTO>> GetWeeklyEarnings()
        {
            var today = DateTime.UtcNow.Date;
            var startOfWeek = today.AddDays(-(int)today.DayOfWeek);
            
            var weeks = new List<WeekEarningsDTO>();

            for (int i = 0; i < 4; i++)
            {
                var weekStart = startOfWeek.AddDays(-7 * i);
                var weekEnd = weekStart.AddDays(7);

                var earnings = await _context.Bookings
                    .Where(b => b.CreatedAt >= weekStart && b.CreatedAt < weekEnd)
                    .Where(b => b.PaymentStatus == PaymentStatus.Paid)
                    .SumAsync(b => b.TotalPrice);

                weeks.Add(new WeekEarningsDTO
                {
                    WeekLabel = $"Week {4 - i}",
                    Earnings = earnings
                });
            }

            weeks.Reverse();

            return Ok(new WeeklyEarningsDTO { Weeks = weeks });
        }

        [HttpGet("booking-status")]
        public async Task<ActionResult<BookingStatusDTO>> GetBookingStatus([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var query = _context.Bookings.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(b => b.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(b => b.CreatedAt <= toDate.Value);

            var total = await query.CountAsync();
            var completed = await query.CountAsync(b => b.Status == BookingStatus.Completed);
            var pending = await query.CountAsync(b => b.Status == BookingStatus.Pending);
            var confirmed = await query.CountAsync(b => b.Status == BookingStatus.Confirmed);
            var cancelled = await query.CountAsync(b => b.Status == BookingStatus.Cancelled);
            var accepted = await query.CountAsync(b => b.Status == BookingStatus.Accepted);
            var expired = await query.CountAsync(b => b.Status == BookingStatus.Expired);

            return Ok(new BookingStatusDTO
            {
                Total = total,
                Completed = completed,
                CompletedPercent = total > 0 ? (decimal)completed / total * 100 : 0,
                Pending = pending,
                PendingPercent = total > 0 ? (decimal)pending / total * 100 : 0,
                Confirmed = confirmed,
                ConfirmedPercent = total > 0 ? (decimal)confirmed / total * 100 : 0,
                Cancelled = cancelled,
                CancelledPercent = total > 0 ? (decimal)cancelled / total * 100 : 0,
                Accepted = accepted,
                AcceptedPercent = total > 0 ? (decimal)accepted / total * 100 : 0,
                Expired = expired,
                ExpiredPercent = total > 0 ? (decimal)expired / total * 100 : 0
            });
        }

        [HttpGet("top-venues")]
        public async Task<ActionResult<TopVenuesDTO>> GetTopVenues([FromQuery] int count = 10)
        {
            var topVenues = await _context.Bookings
                .Where(b => b.PaymentStatus == PaymentStatus.Paid)
                .GroupBy(b => new { b.VenueId, b.Venue.Name })
                .Select(g => new TopVenueDTO
                {
                    VenueId = g.Key.VenueId,
                    VenueName = g.Key.Name,
                    TotalBookings = g.Count(),
                    TotalEarnings = g.Sum(b => b.TotalPrice),
                    AverageRating = _context.Reviews
                        .Where(r => r.VenueId == g.Key.VenueId)
                        .Average(r => (decimal?)r.Rating) ?? 0
                })
                .OrderByDescending(v => v.TotalEarnings)
                .Take(count)
                .ToListAsync();

            return Ok(new TopVenuesDTO { Venues = topVenues });
        }

        [HttpGet("active-venues")]
        public async Task<ActionResult<int>> GetActiveVenues()
        {
            var count = await _context.Venues.CountAsync();
            return Ok(count);
        }
    }

    public class StatisticsEarningsDTO
    {
        public decimal TotalEarnings { get; set; }
        public decimal EarningsChangePercent { get; set; }
        public int TotalBookings { get; set; }
        public decimal BookingsChangePercent { get; set; }
        public decimal AveragePerBooking { get; set; }
        public int CompletedBookings { get; set; }
        public int CancelledBookings { get; set; }
    }

    public class WeeklyEarningsDTO
    {
        public List<WeekEarningsDTO> Weeks { get; set; }
    }

    public class WeekEarningsDTO
    {
        public string WeekLabel { get; set; }
        public decimal Earnings { get; set; }
    }

    public class BookingStatusDTO
    {
        public int Total { get; set; }
        public int Completed { get; set; }
        public decimal CompletedPercent { get; set; }
        public int Pending { get; set; }
        public decimal PendingPercent { get; set; }
        public int Confirmed { get; set; }
        public decimal ConfirmedPercent { get; set; }
        public int Cancelled { get; set; }
        public decimal CancelledPercent { get; set; }
        public int Accepted { get; set; }
        public decimal AcceptedPercent { get; set; }
        public int Expired { get; set; }
        public decimal ExpiredPercent { get; set; }
    }

    public class TopVenuesDTO
    {
        public List<TopVenueDTO> Venues { get; set; }
    }

    public class TopVenueDTO
    {
        public int VenueId { get; set; }
        public string VenueName { get; set; }
        public int TotalBookings { get; set; }
        public decimal TotalEarnings { get; set; }
        public decimal AverageRating { get; set; }
    }
}
