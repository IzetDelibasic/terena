using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Mapster;
using Terena.Models.DTOs;
using Terena.Models.Enums;
using Terena.Models.Exceptions;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.BaseServices;
using Terena.Services.Database;
using Terena.Services.Interfaces;
using BCrypt.Net;

namespace Terena.Services
{
    public class UserService : BaseCRUDService<UserModel, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(TerenaDbContext context) : base(context)
        {
        }

        public override IQueryable<User> AddFilter(UserSearchObject search, IQueryable<User> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.Username))
            {
                filteredQuery = filteredQuery.Where(u => u.Username.ToLower().Contains(search.Username.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search.Email))
            {
                filteredQuery = filteredQuery.Where(u => u.Email.ToLower().Contains(search.Email.ToLower()));
            }

            if (search.Status.HasValue)
            {
                filteredQuery = filteredQuery.Where(u => u.Status == search.Status.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Country))
            {
                filteredQuery = filteredQuery.Where(u => u.Country != null && u.Country.ToLower().Contains(search.Country.ToLower()));
            }

            if (search.Role.HasValue)
            {
                filteredQuery = filteredQuery.Where(u => u.Role == search.Role.Value);
            }

            return filteredQuery;
        }

        public override void BeforeInsert(UserInsertRequest request, User entity)
        {
            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            entity.RegistrationDate = DateTime.UtcNow;
            entity.Status = UserStatus.Active;
            entity.Role = request.Role;
        }

        public override void BeforeUpdate(UserUpdateRequest request, User entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            }

            if (!string.IsNullOrWhiteSpace(request.Username))
                entity.Username = request.Username;
            
            if (!string.IsNullOrWhiteSpace(request.Email))
                entity.Email = request.Email;
            
            if (!string.IsNullOrWhiteSpace(request.Phone))
                entity.Phone = request.Phone;
            
            if (!string.IsNullOrWhiteSpace(request.Country))
                entity.Country = request.Country;
            
            if (!string.IsNullOrWhiteSpace(request.Address))
                entity.Address = request.Address;
            
        }

        public async Task<UserModel> BlockUser(int id, string reason)
        {
            var user = await Context.Set<User>().FindAsync(id);
            
            if (user == null)
                throw new Exception("Unable to find user with the provided id!");

            user.Status = UserStatus.Blocked;
            user.BlockReason = reason;
            user.BlockedAt = DateTime.UtcNow;

            await Context.SaveChangesAsync();

            return user.Adapt<UserModel>();
        }

        public async Task<UserModel> UnblockUser(int id)
        {
            var user = await Context.Set<User>().FindAsync(id);
            
            if (user == null)
                throw new Exception("Unable to find user with the provided id!");

            user.Status = UserStatus.Active;
            user.BlockReason = null;
            user.BlockedAt = null;

            await Context.SaveChangesAsync();

            return user.Adapt<UserModel>();
        }

        public async Task<UserStatistics> GetUserStatistics(int id)
        {
            var user = await Context.Set<User>()
                .Include(u => u.Bookings)
                .ThenInclude(b => b.Venue)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                throw new Exception("Unable to find user with the provided id!");

            var bookings = user.Bookings.Where(b => !b.IsDeleted).ToList();

            var totalBookings = bookings.Count;
            var completedBookings = bookings.Count(b => b.Status == BookingStatus.Completed);
            var cancelledBookings = bookings.Count(b => b.Status == BookingStatus.Cancelled);
            var nonCancelledBookings = bookings.Count(b => b.Status != BookingStatus.Cancelled);
            var totalSpent = bookings.Where(b => b.Status != BookingStatus.Cancelled).Sum(b => b.TotalPrice);
            var averagePerBooking = nonCancelledBookings > 0 ? totalSpent / nonCancelledBookings : 0;

            var favoriteVenue = bookings
                .GroupBy(b => b.VenueId)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            return new UserStatistics
            {
                TotalBookings = totalBookings,
                CompletedBookings = completedBookings,
                CancelledBookings = cancelledBookings,
                TotalSpent = totalSpent,
                AveragePerBooking = averagePerBooking,
                FavoriteVenueCount = favoriteVenue?.Count() ?? 0,
                FavoriteVenueName = favoriteVenue?.FirstOrDefault()?.Venue?.Name
            };
        }

        public async Task<UserModel> LoginAsync(string username, string password)
        {
            var user = await Context.Set<User>()
                .FirstOrDefaultAsync(u => u.Username == username || u.Email == username);

            if (user == null)
                throw new UserException("Invalid username or password!");

            if (user.Status == UserStatus.Blocked)
                throw new UserException("Your account has been blocked. Reason: " + user.BlockReason);

            if (!BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
                throw new UserException("Invalid username or password!");

            user.LastLogin = DateTime.UtcNow;
            await Context.SaveChangesAsync();

            return user.Adapt<UserModel>();
        }

        public async Task<UserModel> BlockUserAsync(int userId, string blockReason)
        {
            var user = await Context.Set<User>().FindAsync(userId);
            
            if (user == null)
                throw new Exception("User not found!");

            if (user.Status == UserStatus.Blocked)
                throw new Exception("User is already blocked!");

            user.Status = UserStatus.Blocked;
            user.BlockReason = blockReason;
            user.BlockedAt = DateTime.UtcNow;

            await Context.SaveChangesAsync();

            return GetById(userId);
        }

        public async Task<UserModel> UnblockUserAsync(int userId)
        {
            var user = await Context.Set<User>().FindAsync(userId);
            
            if (user == null)
                throw new Exception("User not found!");

            if (user.Status != UserStatus.Blocked)
                throw new Exception("User is not blocked!");

            user.Status = UserStatus.Active;
            user.BlockReason = null;
            user.BlockedAt = null;

            await Context.SaveChangesAsync();

            return GetById(userId);
        }
    }
}
