using Microsoft.EntityFrameworkCore;
using Terena.Models.Enums;

namespace Terena.Services.Database;

public class ComprehensiveSeeder
{
    private readonly TerenaDbContext _context;

    public ComprehensiveSeeder(TerenaDbContext context)
    {
        _context = context;
    }

    public async Task SeedAsync()
    {
        if (await _context.Users.AnyAsync())
        {
            Console.WriteLine("Database already seeded. Skipping seeding process.");
            return;
        }

        Console.WriteLine("Database is empty. Starting seeding process...");

        var users = new List<User>
        {
            new User
            {
                Username = "Izet",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Test1234"),
                Email = "izet@test.com",
                Phone = "+38761123456",
                Country = "Bosnia and Herzegovina",
                Address = "Sarajevo",
                RegistrationDate = DateTime.Now.AddMonths(-6),
                Role = UserRole.Customer,
                Status = UserStatus.Active
            },
            new User
            {
                Username = "admin",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123"),
                Email = "admin@terena.ba",
                Phone = "+38761987654",
                Country = "Bosnia and Herzegovina",
                Address = "Sarajevo",
                RegistrationDate = DateTime.Now.AddYears(-1),
                Role = UserRole.Admin,
                Status = UserStatus.Active
            },
            new User
            {
                Username = "emir",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Emir123"),
                Email = "emir@test.com",
                Phone = "+38761234567",
                Country = "Bosnia and Herzegovina",
                Address = "Mostar",
                RegistrationDate = DateTime.Now.AddMonths(-3),
                Role = UserRole.Customer,
                Status = UserStatus.Active
            },
            new User
            {
                Username = "Hasan",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Hasan1234"),
                Email = "hasan@test.com",
                Phone = "+38761345678",
                Country = "Bosnia and Herzegovina",
                Address = "Banja Luka",
                RegistrationDate = DateTime.Now.AddMonths(-4),
                Role = UserRole.Customer,
                Status = UserStatus.Active
            },
            new User
            {
                Username = "Kenan",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Kenan123"),
                Email = "kenan@test.com",
                Phone = "+38761456789",
                Country = "Bosnia and Herzegovina",
                Address = "Tuzla",
                RegistrationDate = DateTime.Now.AddMonths(-2),
                Role = UserRole.Customer,
                Status = UserStatus.Active
            },
            new User
            {
                Username = "blocked_user",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Blocked123"),
                Email = "blocked@test.com",
                Phone = "+38761999999",
                Country = "Bosnia and Herzegovina",
                Address = "Sarajevo",
                RegistrationDate = DateTime.Now.AddMonths(-8),
                Role = UserRole.Customer,
                Status = UserStatus.Blocked,
                BlockReason = "Violation of terms of service"
            }
        };
        _context.Users.AddRange(users);
        await _context.SaveChangesAsync();

        var venues = new List<Venue>
        {
            new Venue
            {
                Name = "Hoops Center Banja Luka",
                Location = "Banja Luka",
                Address = "Bulevar Cara Dušana 25, Banja Luka",
                SportType = "Basketball",
                SurfaceType = "Hardwood",
                Description = "Modern indoor basketball court with professional hardwood flooring and excellent lighting.",
                PricePerHour = 30.00m,
                AvailableSlots = 16,
                ContactPhone = "+38751234567",
                ContactEmail = "info@hoopscenter.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = true,
                HasWaterFountain = true,
                HasSeatingArea = true,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Arena Grbavica",
                Location = "Sarajevo",
                Address = "Safeta Zajke 1, Sarajevo",
                SportType = "Football",
                SurfaceType = "Grass",
                Description = "Historic football stadium with natural grass pitch in the heart of Sarajevo.",
                PricePerHour = 40.00m,
                AvailableSlots = 14,
                ContactPhone = "+38733111222",
                ContactEmail = "info@grbavica.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = false,
                HasCafeBar = true,
                HasWaterFountain = true,
                HasSeatingArea = true,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Grand Slam Tennis Club",
                Location = "Mostar",
                Address = "Splitska bb, Mostar",
                SportType = "Tennis",
                SurfaceType = "Clay",
                Description = "Professional clay tennis courts with beautiful views of the old town.",
                PricePerHour = 25.00m,
                AvailableSlots = 12,
                ContactPhone = "+38736333444",
                ContactEmail = "info@grandslam.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = false,
                HasWaterFountain = true,
                HasSeatingArea = false,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Ace Tennis Academy",
                Location = "Sarajevo",
                Address = "Patriotske lige 45, Sarajevo",
                SportType = "Tennis",
                SurfaceType = "Grass",
                Description = "Modern tennis academy with grass and professional coaching available.",
                PricePerHour = 28.00m,
                AvailableSlots = 10,
                ContactPhone = "+38733555666",
                ContactEmail = "info@acetennis.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1595435742656-5272d0f23c82?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = true,
                HasWaterFountain = true,
                HasSeatingArea = true,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Arena Neum",
                Location = "Neum",
                Address = "Neum bb, Neum",
                SportType = "Basketball",
                SurfaceType = "Hardwood",
                Description = "Professional indoor basketball arena with seating for spectators.",
                PricePerHour = 35.00m,
                AvailableSlots = 12,
                ContactPhone = "+38732777888",
                ContactEmail = "info@arenaneum.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = true,
                HasWaterFountain = true,
                HasSeatingArea = true,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Skyline Basketball Arena",
                Location = "Sarajevo",
                Address = "Hrasno, Sarajevo",
                SportType = "Basketball",
                SurfaceType = "Clay",
                Description = "State-of-the-art basketball arena with clay flooring and modern amenities.",
                PricePerHour = 35.00m,
                AvailableSlots = 16,
                ContactPhone = "+38733999000",
                ContactEmail = "info@skylinearena.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = false,
                HasCafeBar = true,
                HasWaterFountain = true,
                HasSeatingArea = true,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Stadium Five Mostar",
                Location = "Mostar",
                Address = "Slavinovići, Mostar",
                SportType = "Football",
                SurfaceType = "Grass",
                Description = "Modern 5-a-side football pitch with high-quality grass turf.",
                PricePerHour = 32.00m,
                AvailableSlots = 18,
                ContactPhone = "+38735111222",
                ContactEmail = "info@stadiumfive.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = true,
                HasWaterFountain = true,
                HasSeatingArea = false,
                IsDeleted = false
            },
            new Venue
            {
                Name = "Deleted Test Venue",
                Location = "Sarajevo",
                Address = "Test Address, Sarajevo",
                SportType = "Football",
                SurfaceType = "Grass",
                Description = "This venue has been deleted for testing purposes.",
                PricePerHour = 50.00m,
                AvailableSlots = 10,
                ContactPhone = "+38733000000",
                ContactEmail = "deleted@test.ba",
                VenueImageUrl = "https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800",
                HasParking = false,
                HasShowers = false,
                HasLighting = false,
                HasChangingRooms = false,
                HasEquipmentRental = false,
                HasCafeBar = false,
                HasWaterFountain = false,
                HasSeatingArea = false,
                IsDeleted = true,
                DeleteTime = DateTime.Now.AddDays(-5)
            }
        };
        _context.Venues.AddRange(venues);
        await _context.SaveChangesAsync();

        foreach (var venue in venues.Where(v => !v.IsDeleted))
        {
            _context.CancellationPolicies.Add(new CancellationPolicy
            {
                VenueId = venue.Id,
                Fee = 50.0m
            });

            _context.Discounts.Add(new Discount
            {
                VenueId = venue.Id,
                Percentage = 10.0m,
                ForBookings = 3
            });
        }
        await _context.SaveChangesAsync();

        foreach (var venue in venues.Where(v => !v.IsDeleted))
        {
            var courtCount = venue.SportType == "Football" ? 2 : venue.SportType == "Basketball" ? 3 : 4;
            for (int i = 1; i <= courtCount; i++)
            {
                _context.Courts.Add(new Court
                {
                    Name = $"Court {i}",
                    VenueId = venue.Id,
                    CourtType = venue.SportType,
                    IsAvailable = true,
                    MaxCapacity = "20"
                });
            }
        }
        await _context.SaveChangesAsync();

        var activeVenues = venues.Where(v => !v.IsDeleted).ToList();
        var activeUsers = users.Where(u => u.Status == UserStatus.Active && u.Role == UserRole.Customer).ToList();

        var bookings = new List<Booking>
        {
            new Booking
            {
                UserId = users[0].Id, 
                VenueId = activeVenues[5].Id,
                CourtId = _context.Courts.First(c => c.VenueId == activeVenues[5].Id).Id,
                BookingDate = DateTime.Now.AddDays(2),
                StartTime = DateTime.Now.AddDays(2).Date.AddHours(19),
                EndTime = DateTime.Now.AddDays(2).Date.AddHours(20),
                BookingNumber = "BK20260116121410410",
                Duration = 1,
                NumberOfPlayers = 10,
                IsGroupBooking = false,
                PricePerHour = 35.00m,
                SubtotalPrice = 35.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 1.75m,
                TotalPrice = 36.75m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Now.AddDays(-1),
                IsRefunded = false
            },
            new Booking
            {
                UserId = users[0].Id, 
                VenueId = activeVenues[0].Id,
                CourtId = _context.Courts.First(c => c.VenueId == activeVenues[0].Id).Id,
                BookingDate = DateTime.Now.AddDays(5),
                StartTime = DateTime.Now.AddDays(5).Date.AddHours(18),
                EndTime = DateTime.Now.AddDays(5).Date.AddHours(20),
                BookingNumber = "BK20260119180000001",
                Duration = 2,
                NumberOfPlayers = 10,
                IsGroupBooking = false,
                PricePerHour = 30.00m,
                SubtotalPrice = 60.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 3.00m,
                TotalPrice = 63.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Now.AddHours(-5),
                IsRefunded = false
            },
            new Booking
            {
                UserId = users[2].Id, 
                VenueId = activeVenues[2].Id, 
                CourtId = _context.Courts.First(c => c.VenueId == activeVenues[2].Id).Id,
                BookingDate = DateTime.Now.AddDays(3),
                StartTime = DateTime.Now.AddDays(3).Date.AddHours(16),
                EndTime = DateTime.Now.AddDays(3).Date.AddHours(17),
                BookingNumber = "BK20260117160000002",
                Duration = 1,
                NumberOfPlayers = 2,
                IsGroupBooking = false,
                PricePerHour = 25.00m,
                SubtotalPrice = 25.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 1.25m,
                TotalPrice = 26.25m,
                Status = BookingStatus.Confirmed,
                PaymentStatus = PaymentStatus.Paid,
                StripePaymentIntentId = "pi_test_confirmed_001",
                PaidAt = DateTime.Now.AddDays(-2),
                CreatedAt = DateTime.Now.AddDays(-2),
                ConfirmedAt = DateTime.Now.AddDays(-2),
                IsRefunded = false
            },
            new Booking
            {
                UserId = users[0].Id, 
                VenueId = activeVenues[1].Id, 
                CourtId = _context.Courts.First(c => c.VenueId == activeVenues[1].Id).Id,
                BookingDate = DateTime.Now.AddDays(-3),
                StartTime = DateTime.Now.AddDays(-3).Date.AddHours(18),
                EndTime = DateTime.Now.AddDays(-3).Date.AddHours(20),
                BookingNumber = "BK20260111180000003",
                Duration = 2,
                NumberOfPlayers = 10,
                IsGroupBooking = true,
                PricePerHour = 40.00m,
                SubtotalPrice = 80.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 4.00m,
                TotalPrice = 84.00m,
                Status = BookingStatus.Completed,
                PaymentStatus = PaymentStatus.Paid,
                StripePaymentIntentId = "pi_test_completed_001",
                PaidAt = DateTime.Now.AddDays(-5),
                CreatedAt = DateTime.Now.AddDays(-5),
                CompletedAt = DateTime.Now.AddDays(-3),
                IsRefunded = false
            },
            new Booking
            {
                UserId = users[3].Id, 
                VenueId = activeVenues[4].Id,
                CourtId = _context.Courts.First(c => c.VenueId == activeVenues[4].Id).Id,
                BookingDate = DateTime.Now.AddDays(-7),
                StartTime = DateTime.Now.AddDays(-7).Date.AddHours(19),
                EndTime = DateTime.Now.AddDays(-7).Date.AddHours(21),
                BookingNumber = "BK20260107190000004",
                Duration = 2,
                NumberOfPlayers = 8,
                IsGroupBooking = true,
                PricePerHour = 35.00m,
                SubtotalPrice = 70.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 3.50m,
                TotalPrice = 73.50m,
                Status = BookingStatus.Completed,
                PaymentStatus = PaymentStatus.Paid,
                StripePaymentIntentId = "pi_test_completed_002",
                PaidAt = DateTime.Now.AddDays(-10),
                CreatedAt = DateTime.Now.AddDays(-10),
                CompletedAt = DateTime.Now.AddDays(-7),
                IsRefunded = false
            },
            new Booking
            {
                UserId = users[2].Id, 
                VenueId = activeVenues[0].Id, 
                CourtId = _context.Courts.First(c => c.VenueId == activeVenues[0].Id).Id,
                BookingDate = DateTime.Now.AddDays(-1),
                StartTime = DateTime.Now.AddDays(-1).Date.AddHours(20),
                EndTime = DateTime.Now.AddDays(-1).Date.AddHours(21),
                BookingNumber = "BK20260113200000005",
                Duration = 1,
                NumberOfPlayers = 5,
                IsGroupBooking = false,
                PricePerHour = 30.00m,
                SubtotalPrice = 30.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 1.50m,
                TotalPrice = 31.50m,
                Status = BookingStatus.Cancelled,
                PaymentStatus = PaymentStatus.Refunded,
                StripePaymentIntentId = "pi_test_cancelled_001",
                StripeRefundId = "re_test_cancelled_001",
                RefundAmount = 16.00m,
                RefundedAt = DateTime.Now.AddDays(-2),
                CancellationReason = "User requested cancellation",
                CancelledAt = DateTime.Now.AddDays(-2),
                CreatedAt = DateTime.Now.AddDays(-4),
                IsRefunded = true
            }
        };
        _context.Bookings.AddRange(bookings);
        await _context.SaveChangesAsync();

        var completedBookings = bookings.Where(b => b.Status == BookingStatus.Completed).ToList();
        var reviews = new List<Review>
        {
            new Review
            {
                UserId = completedBookings[0].UserId,
                VenueId = completedBookings[0].VenueId,
                BookingId = completedBookings[0].Id,
                Rating = 5,
                Comment = "Odličan teren! Sve je bilo perfektno organizovano.",
                CreatedAt = DateTime.Now.AddDays(-2)
            },
            new Review
            {
                UserId = completedBookings[1].UserId,
                VenueId = completedBookings[1].VenueId,
                BookingId = completedBookings[1].Id,
                Rating = 4,
                Comment = "Jako dobar teren, jedino parking malo udaljen.",
                CreatedAt = DateTime.Now.AddDays(-6)
            }
        };
        _context.Reviews.AddRange(reviews);
        await _context.SaveChangesAsync();

        var favorites = new List<UserFavoriteVenue>
        {
            new UserFavoriteVenue
            {
                UserId = users[0].Id,
                VenueId = activeVenues[0].Id,
                CreatedAt = DateTime.Now.AddMonths(-1)
            },
            new UserFavoriteVenue
            {
                UserId = users[0].Id, 
                VenueId = activeVenues[2].Id, 
                CreatedAt = DateTime.Now.AddMonths(-2)
            },
            new UserFavoriteVenue
            {
                UserId = users[2].Id, 
                VenueId = activeVenues[1].Id,
                CreatedAt = DateTime.Now.AddDays(-15)
            }
        };
        _context.UserFavoriteVenues.AddRange(favorites);
        await _context.SaveChangesAsync();

        Console.WriteLine("Comprehensive seeding completed successfully!");
        Console.WriteLine($"Created {users.Count} users (including 1 blocked user)");
        Console.WriteLine($"Created {venues.Count} venues (including 1 soft-deleted venue)");
        Console.WriteLine($"Created {bookings.Count} bookings in various states");
        Console.WriteLine($"Created {reviews.Count} reviews");
        Console.WriteLine($"Created {favorites.Count} favorites");
    }
}
