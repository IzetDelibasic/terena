using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Mapster;
using Terena.Models.DTOs;
using Terena.Models.Enums;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseServices;
using Terena.Services.Database;
using Terena.Services.Interfaces;

namespace Terena.Services
{
    public class BookingService : BaseCRUDService<BookingDTO, BookingSearchObject, Booking, BookingInsertRequest, BookingUpdateRequest>, IBookingService
    {
        public BookingService(TerenaDbContext context) : base(context)
        {
        }

        public override BookingDTO Insert(BookingInsertRequest request)
        {
            var entity = new Booking();
            
            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();
            
            AfterInsert(request, entity);

            var savedEntity = Context.Set<Booking>()
                .Include(b => b.User)
                .Include(b => b.Venue)
                .Include(b => b.Court)
                .FirstOrDefault(b => b.Id == entity.Id);

            if (savedEntity == null)
                throw new Exception("Failed to create booking");

            return savedEntity.Adapt<BookingDTO>();
        }

        public override IQueryable<Booking> AddFilter(BookingSearchObject search, IQueryable<Booking> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.BookingNumber))
            {
                filteredQuery = filteredQuery.Where(b => b.BookingNumber.Contains(search.BookingNumber));
            }

            if (search.UserId.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.UserId == search.UserId.Value);
            }

            if (search.VenueId.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.VenueId == search.VenueId.Value);
            }

            if (search.CourtId.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.CourtId == search.CourtId.Value);
            }

            if (search.BookingDateFrom.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.BookingDate >= search.BookingDateFrom.Value);
            }

            if (search.BookingDateTo.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.BookingDate <= search.BookingDateTo.Value);
            }

            if (search.Status.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.Status == search.Status.Value);
            }

            if (search.PaymentStatus.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.PaymentStatus == search.PaymentStatus.Value);
            }

            if (search.IsRefunded.HasValue)
            {
                filteredQuery = filteredQuery.Where(b => b.IsRefunded == search.IsRefunded.Value);
            }

            return filteredQuery;
        }

        public override async Task<Terena.Models.HelperClasses.PagedResult<BookingDTO>> GetPagedAsync(BookingSearchObject search)
        {
            var query = Context.Set<Booking>()
                .Include(b => b.User)
                .Include(b => b.Venue)
                .Include(b => b.Court)
                .AsQueryable();

            if (!string.IsNullOrEmpty(search?.IncludeTables))
            {
                query = ApplyIncludes(query, search.IncludeTables);
            }

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }

            if (search != null && search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            var result = list.Adapt<System.Collections.Generic.List<BookingDTO>>();

            return new Terena.Models.HelperClasses.PagedResult<BookingDTO>
            {
                ResultList = result,
                Count = count
            };
        }

        public override BookingDTO GetById(int id)
        {
            var entity = Context.Set<Booking>()
                .Include(b => b.User)
                .Include(b => b.Venue)
                .Include(b => b.Court)
                .FirstOrDefault(b => b.Id == id);

            if (entity == null)
                return null;

            return entity.Adapt<BookingDTO>();
        }

        public override void BeforeInsert(BookingInsertRequest request, Booking entity)
        {
            var requestStartUtc = request.StartTime.ToUniversalTime();
            var requestEndUtc = request.EndTime.ToUniversalTime();
            
            var hasConflict = Context.Set<Booking>()
                .Any(b => b.VenueId == request.VenueId
                    && (request.CourtId == null || b.CourtId == request.CourtId)
                    && b.Status != BookingStatus.Cancelled
                    && b.StartTime < requestEndUtc
                    && b.EndTime > requestStartUtc);

            if (hasConflict)
            {
                throw new Exception("This time slot is already booked!");
            }

            entity.BookingNumber = GenerateBookingNumber();
            entity.CreatedAt = DateTime.UtcNow;
            entity.Status = BookingStatus.Pending;
            entity.PaymentStatus = PaymentStatus.Pending;
            entity.BookingDate = request.BookingDate.ToUniversalTime();
            entity.StartTime = requestStartUtc;
            entity.EndTime = requestEndUtc;
            entity.PricePerHour = request.PricePerHour;
            entity.UserId = request.UserId;
            entity.VenueId = request.VenueId;
            entity.CourtId = request.CourtId;
            entity.NumberOfPlayers = request.NumberOfPlayers;
            entity.IsGroupBooking = request.IsGroupBooking;
            entity.Notes = request.Notes;
            var duration = (request.EndTime - request.StartTime).TotalHours;
            entity.Duration = (decimal)duration;
            entity.SubtotalPrice = entity.Duration * request.PricePerHour;
            
            var venue = Context.Set<Venue>()
                .Include(v => v.Discount)
                .FirstOrDefault(v => v.Id == request.VenueId);
            
            entity.DiscountPercentage = 0;
            if (venue?.Discount != null && venue.Discount.Percentage > 0 && venue.Discount.ForBookings > 0)
            {
                if (entity.Duration >= venue.Discount.ForBookings)
                {
                    entity.DiscountPercentage = venue.Discount.Percentage;
                }
            }
            
            entity.DiscountAmount = entity.SubtotalPrice * (entity.DiscountPercentage / 100);
            entity.ServiceFee = 0;
            entity.TotalPrice = entity.SubtotalPrice - entity.DiscountAmount + entity.ServiceFee;

            int cancellationPolicyHours = 24;
            if (venue != null && venue.CancellationPolicyHours.HasValue)
            {
                cancellationPolicyHours = venue.CancellationPolicyHours.Value;
            }
            entity.CancellationDeadline = request.StartTime.AddHours(-cancellationPolicyHours);

            entity.PaymentMethod = request.PaymentMethod;
            entity.IsDeleted = false;
        }

        public override void BeforeUpdate(BookingUpdateRequest request, Booking entity)
        {
            if (request.StartTime.HasValue)
            {
                entity.StartTime = request.StartTime.Value;
                
                if (request.EndTime.HasValue)
                {
                    entity.EndTime = request.EndTime.Value;
                    var duration = (entity.EndTime - entity.StartTime).TotalHours;
                    entity.Duration = (decimal)duration;
                    entity.SubtotalPrice = entity.Duration * entity.PricePerHour;
                    entity.DiscountAmount = entity.SubtotalPrice * (entity.DiscountPercentage / 100);
                    entity.TotalPrice = entity.SubtotalPrice - entity.DiscountAmount + entity.ServiceFee;
                }
            }

            if (request.Status.HasValue)
            {
                entity.Status = request.Status.Value;
                
                if (request.Status.Value == BookingStatus.Cancelled && !string.IsNullOrEmpty(request.CancellationReason))
                {
                    entity.CancellationReason = request.CancellationReason;
                    entity.CancelledAt = DateTime.UtcNow;
                }
                else if (request.Status.Value == BookingStatus.Confirmed)
                {
                    entity.ConfirmedAt = DateTime.UtcNow;
                }
                else if (request.Status.Value == BookingStatus.Completed)
                {
                    entity.CompletedAt = DateTime.UtcNow;
                }
            }

            if (request.PaymentStatus.HasValue)
            {
                entity.PaymentStatus = request.PaymentStatus.Value;
                
                if (request.PaymentStatus.Value == PaymentStatus.Paid)
                {
                    entity.PaidAt = DateTime.UtcNow;
                }
            }

            if (!string.IsNullOrEmpty(request.TransactionId))
            {
                entity.TransactionId = request.TransactionId;
            }

            if (!string.IsNullOrEmpty(request.PaymentMethod))
            {
                entity.PaymentMethod = request.PaymentMethod;
            }
        }

        public async Task<BookingDTO> ConfirmBookingAsync(int bookingId)
        {
            var booking = await Context.Set<Booking>().FindAsync(bookingId);
            
            if (booking == null)
                throw new Exception("Booking not found!");

            if (booking.Status != BookingStatus.Pending)
                throw new Exception("Only pending bookings can be confirmed!");

            booking.Status = BookingStatus.Confirmed;
            booking.ConfirmedAt = DateTime.UtcNow;

            await Context.SaveChangesAsync();
            return GetById(bookingId);
        }

        public async Task<BookingDTO> CancelBookingAsync(int bookingId, string cancellationReason)
        {
            var booking = await Context.Set<Booking>().FindAsync(bookingId);
            
            if (booking == null)
                throw new Exception("Booking not found!");

            if (booking.Status == BookingStatus.Cancelled)
                throw new Exception("Booking is already cancelled!");

            if (booking.Status == BookingStatus.Completed)
                throw new Exception("Cannot cancel completed booking!");

            booking.Status = BookingStatus.Cancelled;
            booking.CancellationReason = cancellationReason;
            booking.CancelledAt = DateTime.UtcNow;

            await Context.SaveChangesAsync();
            return GetById(bookingId);
        }

        public async Task<BookingDTO> CompleteBookingAsync(int bookingId)
        {
            var booking = await Context.Set<Booking>().FindAsync(bookingId);
            
            if (booking == null)
                throw new Exception("Booking not found!");

            if (booking.Status != BookingStatus.Confirmed)
                throw new Exception("Only confirmed bookings can be completed!");

            booking.Status = BookingStatus.Completed;
            booking.CompletedAt = DateTime.UtcNow;

            await Context.SaveChangesAsync();
            return GetById(bookingId);
        }

        public async Task<BookingDTO> ProcessPaymentAsync(int bookingId, string transactionId)
        {
            var booking = await Context.Set<Booking>().FindAsync(bookingId);
            
            if (booking == null)
                throw new Exception("Booking not found!");

            if (booking.PaymentStatus == PaymentStatus.Paid)
                throw new Exception("Booking is already paid!");

            booking.PaymentStatus = PaymentStatus.Paid;
            booking.TransactionId = transactionId;
            booking.PaidAt = DateTime.UtcNow;

            await Context.SaveChangesAsync();
            return GetById(bookingId);
        }

        public async Task<BookingDTO> RefundBookingAsync(int bookingId, decimal? refundAmount = null)
        {
            var booking = await Context.Set<Booking>().FindAsync(bookingId);
            
            if (booking == null)
                throw new Exception("Booking not found!");

            if (booking.PaymentStatus != PaymentStatus.Paid)
                throw new Exception("Only paid bookings can be refunded!");

            if (booking.IsRefunded)
                throw new Exception("Booking is already refunded!");

            booking.IsRefunded = true;
            booking.RefundAmount = refundAmount ?? booking.TotalPrice;
            booking.RefundedAt = DateTime.UtcNow;
            booking.PaymentStatus = booking.RefundAmount >= booking.TotalPrice 
                ? PaymentStatus.Refunded 
                : PaymentStatus.PartiallyRefunded;

            await Context.SaveChangesAsync();

            return await Task.FromResult(GetById(bookingId));
        }

        private string GenerateBookingNumber()
        {
            return $"BK{DateTime.UtcNow:yyyyMMddHHmmss}{new Random().Next(1000, 9999)}";
        }

        public async Task<List<string>> GetAvailableTimeSlotsAsync(int venueId, DateTime date, int? courtId = null)
        {
            var startHour = 8; 
            var endHour = 22;  
            
            var availableSlots = new List<string>();
            
            var dateUtc = date.ToUniversalTime().Date;
            
            var bookings = await Context.Set<Booking>()
                .Where(b => b.VenueId == venueId
                    && (courtId == null || b.CourtId == courtId)
                    && b.StartTime.Date == dateUtc
                    && b.Status != BookingStatus.Cancelled)
                .ToListAsync();
            
            for (int hour = startHour; hour < endHour; hour++)
            {
                var slotTime = new DateTime(dateUtc.Year, dateUtc.Month, dateUtc.Day, hour, 0, 0, DateTimeKind.Utc);
                var slotEndTime = slotTime.AddHours(1);
                
                bool isAvailable = !bookings.Any(b => 
                    (slotTime >= b.StartTime && slotTime < b.EndTime) ||
                    (slotEndTime > b.StartTime && slotEndTime <= b.EndTime) ||
                    (slotTime <= b.StartTime && slotEndTime >= b.EndTime));
                
                if (isAvailable)
                {
                    availableSlots.Add($"{hour:D2}:00");
                }
            }
            
            return availableSlots;
        }
    }
}
