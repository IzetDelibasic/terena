using Microsoft.EntityFrameworkCore;
using Terena.Models.Enums;

namespace Terena.Services.Database;

public class DatabaseSeeder
{
    private readonly TerenaDbContext _context;

    public DatabaseSeeder(TerenaDbContext context)
    {
        _context = context;
    }

    public async Task SeedAsync()
    {
        if (await _context.Users.AnyAsync())
        {
            return; 
        }

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
            }
        };
        _context.Users.AddRange(users);
        await _context.SaveChangesAsync();

        var venues = new List<Venue>
        {
            new Venue
            {
                Name = "Stadium Alpha",
                Location = "Sarajevo",
                Address = "Zmaja od Bosne bb, Sarajevo 71000",
                SportType = "Football",
                SurfaceType = "Artificial Turf",
                Description = "Professional football stadium with top-quality artificial turf and night lighting.",
                PricePerHour = 45.00m,
                AvailableSlots = 18,
                ContactPhone = "+38733123456",
                ContactEmail = "info@stadiumalpha.ba",
                VenueImageUrl = "/images/stadium-alpha.jpg",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = false,
                HasCafeBar = true,
                CancellationPolicyHours = 24,
                CancellationFeePercentage = 50,
                RefundProcessingDays = 5,
                DiscountPercentage = 10,
                DiscountThreshold = 3
            },
            new Venue
            {
                Name = "Elite Padel Club",
                Location = "Banja Luka",
                Address = "Banja Luka Centar, 78000",
                SportType = "Padel",
                SurfaceType = "Artificial Grass",
                Description = "Premium padel courts with professional equipment and coaching available.",
                PricePerHour = 50.00m,
                AvailableSlots = 12,
                ContactPhone = "+38751987654",
                ContactEmail = "info@elitepadel.ba",
                VenueImageUrl = "/images/elite-padel.jpg",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = true,
                CancellationPolicyHours = 24,
                CancellationFeePercentage = 50,
                RefundProcessingDays = 3,
                DiscountPercentage = 10,
                DiscountThreshold = 3
            },
            new Venue
            {
                Name = "Skyline Court",
                Location = "Mostar",
                Address = "Mostar Centar, 88000",
                SportType = "Basketball",
                SurfaceType = "Hardwood",
                Description = "Modern basketball courts with excellent facilities and city views.",
                PricePerHour = 35.00m,
                AvailableSlots = 15,
                ContactPhone = "+38736456789",
                ContactEmail = "info@skylinecourt.ba",
                VenueImageUrl = "/images/skyline-court.jpg",
                HasParking = false,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = false,
                HasCafeBar = false,
                CancellationPolicyHours = 24,
                CancellationFeePercentage = 50,
                RefundProcessingDays = 5
            },
            new Venue
            {
                Name = "Beach Volley Paradise",
                Location = "Neum",
                Address = "Obala bb, Neum 88390",
                SportType = "Volleyball",
                SurfaceType = "Sand",
                Description = "Beautiful beach volleyball courts right by the sea.",
                PricePerHour = 30.00m,
                AvailableSlots = 10,
                ContactPhone = "+38736321654",
                ContactEmail = "info@beachvolley.ba",
                VenueImageUrl = "/images/beach-volley.jpg",
                HasParking = true,
                HasShowers = true,
                HasLighting = false,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = true,
                CancellationPolicyHours = 24,
                CancellationFeePercentage = 50,
                RefundProcessingDays = 3
            },
            new Venue
            {
                Name = "Central 5-a-Side",
                Location = "Sarajevo",
                Address = "Grbavica, Sarajevo 71000",
                SportType = "Mini Football",
                SurfaceType = "Artificial Turf",
                Description = "Perfect 5-a-side football venue in the heart of the city.",
                PricePerHour = 40.00m,
                AvailableSlots = 16,
                ContactPhone = "+38733789456",
                ContactEmail = "info@central5.ba",
                VenueImageUrl = "/images/central-5.jpg",
                HasParking = true,
                HasShowers = true,
                HasLighting = true,
                HasChangingRooms = true,
                HasEquipmentRental = false,
                HasCafeBar = false,
                CancellationPolicyHours = 24,
                CancellationFeePercentage = 50,
                RefundProcessingDays = 5,
                DiscountPercentage = 10,
                DiscountThreshold = 3
            },
            new Venue
            {
                Name = "Grand Slam Tennis",
                Location = "Sarajevo",
                Address = "Ilidza, Sarajevo 71000",
                SportType = "Tennis",
                SurfaceType = "Clay",
                Description = "Professional tennis courts with clay and hard surfaces available.",
                PricePerHour = 25.00m,
                AvailableSlots = 14,
                ContactPhone = "+38733654321",
                ContactEmail = "info@grandslam.ba",
                VenueImageUrl = "/images/grand-slam.jpg",
                HasParking = true,
                HasShowers = false,
                HasLighting = false,
                HasChangingRooms = true,
                HasEquipmentRental = true,
                HasCafeBar = false,
                CancellationPolicyHours = 24,
                CancellationFeePercentage = 50,
                RefundProcessingDays = 5
            }
        };
        _context.Venues.AddRange(venues);
        await _context.SaveChangesAsync();

        var courts = new List<Court>();
        foreach (var venue in venues)
        {
            if (venue.SportType == "Football" || venue.SportType == "Mini Football")
            {
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Field A",
                    CourtType = "5v5/7v7",
                    MaxCapacity = "14",
                    IsAvailable = true
                });
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Field B",
                    CourtType = "5v5/7v7",
                    MaxCapacity = "14",
                    IsAvailable = true
                });
            }
            else if (venue.SportType == "Basketball")
            {
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Court 1",
                    CourtType = "Full Court",
                    MaxCapacity = "10",
                    IsAvailable = true
                });
            }
            else if (venue.SportType == "Tennis")
            {
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Court 1 - Clay",
                    CourtType = "Singles/Doubles",
                    MaxCapacity = "4",
                    IsAvailable = true
                });
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Court 2 - Hard",
                    CourtType = "Singles/Doubles",
                    MaxCapacity = "4",
                    IsAvailable = true
                });
            }
            else if (venue.SportType == "Padel")
            {
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Padel Court 1",
                    CourtType = "Doubles",
                    MaxCapacity = "4",
                    IsAvailable = true
                });
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Padel Court 2",
                    CourtType = "Doubles",
                    MaxCapacity = "4",
                    IsAvailable = true
                });
            }
            else if (venue.SportType == "Volleyball")
            {
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Beach Court 1",
                    CourtType = "2v2/4v4",
                    MaxCapacity = "8",
                    IsAvailable = true
                });
            }
        }
        _context.Courts.AddRange(courts);
        await _context.SaveChangesAsync();

        var bookings = new List<Booking>
        {
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venues[0].Id,
                CourtId = courts[0].Id,
                BookingNumber = "TER001",
                BookingDate = DateTime.Now.AddDays(5),
                StartTime = DateTime.Now.AddDays(5).Date.AddHours(18),
                EndTime = DateTime.Now.AddDays(5).Date.AddHours(20),
                Duration = 2,
                NumberOfPlayers = 10,
                PricePerHour = 45.00m,
                SubtotalPrice = 90.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 90.00m,
                Status = BookingStatus.Confirmed,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Now.AddDays(-2),
                ConfirmedAt = DateTime.Now.AddDays(-2),
                PaidAt = DateTime.Now.AddDays(-2)
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venues[1].Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venues[1].Id)?.Id,
                BookingNumber = "TER002",
                BookingDate = DateTime.Now.AddDays(6),
                StartTime = DateTime.Now.AddDays(6).Date.AddHours(10),
                EndTime = DateTime.Now.AddDays(6).Date.AddHours(12),
                Duration = 2,
                NumberOfPlayers = 4,
                PricePerHour = 50.00m,
                SubtotalPrice = 100.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 100.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Now.AddDays(-1)
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venues[2].Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venues[2].Id)?.Id,
                BookingNumber = "TER003",
                BookingDate = DateTime.Now.AddDays(-5),
                StartTime = DateTime.Now.AddDays(-5).Date.AddHours(16),
                EndTime = DateTime.Now.AddDays(-5).Date.AddHours(18),
                Duration = 2,
                NumberOfPlayers = 8,
                PricePerHour = 35.00m,
                SubtotalPrice = 70.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 70.00m,
                Status = BookingStatus.Completed,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Now.AddDays(-10),
                ConfirmedAt = DateTime.Now.AddDays(-10),
                CompletedAt = DateTime.Now.AddDays(-5),
                PaidAt = DateTime.Now.AddDays(-10)
            },
            new Booking
            {
                UserId = users[2].Id,
                VenueId = venues[0].Id,
                CourtId = courts[1].Id,
                BookingNumber = "TER004",
                BookingDate = DateTime.Now.AddDays(-10),
                StartTime = DateTime.Now.AddDays(-10).Date.AddHours(14),
                EndTime = DateTime.Now.AddDays(-10).Date.AddHours(16),
                Duration = 2,
                NumberOfPlayers = 10,
                PricePerHour = 45.00m,
                SubtotalPrice = 90.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 90.00m,
                Status = BookingStatus.Completed,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Now.AddDays(-15),
                ConfirmedAt = DateTime.Now.AddDays(-15),
                CompletedAt = DateTime.Now.AddDays(-10),
                PaidAt = DateTime.Now.AddDays(-15)
            }
        };
        _context.Bookings.AddRange(bookings);
        await _context.SaveChangesAsync();

        var reviews = new List<Review>
        {
            new Review
            {
                UserId = users[0].Id,
                VenueId = venues[0].Id,
                Rating = 5,
                Comment = "Excellent venue! Great facilities and very well maintained.",
                CreatedAt = DateTime.Now.AddDays(-3)
            },
            new Review
            {
                UserId = users[2].Id,
                VenueId = venues[0].Id,
                Rating = 5,
                Comment = "Perfect for evening games. Lighting is great!",
                CreatedAt = DateTime.Now.AddDays(-8)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venues[1].Id,
                Rating = 5,
                Comment = "Best padel club in town! Professional service.",
                CreatedAt = DateTime.Now.AddDays(-2)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venues[2].Id,
                Rating = 4,
                Comment = "Good basketball court, could use better parking.",
                CreatedAt = DateTime.Now.AddDays(-4)
            }
        };
        _context.Reviews.AddRange(reviews);
        await _context.SaveChangesAsync();

        var favorites = new List<UserFavoriteVenue>
        {
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venues[0].Id, CreatedAt = DateTime.Now.AddDays(-10) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venues[1].Id, CreatedAt = DateTime.Now.AddDays(-8) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venues[2].Id, CreatedAt = DateTime.Now.AddDays(-5) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venues[5].Id, CreatedAt = DateTime.Now.AddDays(-3) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venues[4].Id, CreatedAt = DateTime.Now.AddDays(-1) },
        };
        _context.UserFavoriteVenues.AddRange(favorites);
        await _context.SaveChangesAsync();

        Console.WriteLine("Database seeded successfully!");
    }
}

