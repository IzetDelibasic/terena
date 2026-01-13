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
        _context.UserFavoriteVenues.RemoveRange(_context.UserFavoriteVenues);
        _context.Reviews.RemoveRange(_context.Reviews);
        _context.Bookings.RemoveRange(_context.Bookings);
        _context.Courts.RemoveRange(_context.Courts);
        _context.CancellationPolicies.RemoveRange(_context.CancellationPolicies);
        _context.Discounts.RemoveRange(_context.Discounts);
        _context.Venues.RemoveRange(_context.Venues);
        _context.Users.RemoveRange(_context.Users);
        await _context.SaveChangesAsync();

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

        var venue1 = new Venue
        {
            Name = "Stadium Alpha",
            Location = "Mostar",
            Address = "Bulevar bb, Mostar 88000",
            SportType = "Football",
            SurfaceType = "Grass",
            Description = "Professional football stadium with top-quality grass and excellent facilities.",
            PricePerHour = 45.00m,
            AvailableSlots = 18,
            ContactPhone = "+38736123456",
            ContactEmail = "info@stadiumalpha.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = false,
            HasCafeBar = true,
            HasWaterFountain = true,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue1);
        await _context.SaveChangesAsync();

        var cancellation1 = new CancellationPolicy
        {
            VenueId = venue1.Id,
            FreeUntil = DateTime.Now.AddDays(30),
            Fee = 50.0m
        };
        var discount1 = new Discount
        {
            VenueId = venue1.Id,
            Percentage = 10.0m,
            ForBookings = 3
        };
        _context.CancellationPolicies.Add(cancellation1);
        _context.Discounts.Add(discount1);
        await _context.SaveChangesAsync();

        var venue2 = new Venue
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
            VenueImageUrl = "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = true,
            HasWaterFountain = false,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue2);
        await _context.SaveChangesAsync();

        var cancellation2 = new CancellationPolicy
        {
            VenueId = venue2.Id,
            FreeUntil = DateTime.Now.AddDays(30),
            Fee = 50.0m
        };
        var discount2 = new Discount
        {
            VenueId = venue2.Id,
            Percentage = 15.0m,
            ForBookings = 3
        };
        _context.CancellationPolicies.Add(cancellation2);
        _context.Discounts.Add(discount2);
        await _context.SaveChangesAsync();

        var venue3 = new Venue
        {
            Name = "Skyline Court",
            Location = "Sarajevo",
            Address = "Ilidza, Sarajevo 71000",
            SportType = "Basketball",
            SurfaceType = "Hardwood",
            Description = "Modern basketball courts with excellent facilities and city views.",
            PricePerHour = 35.00m,
            AvailableSlots = 15,
            ContactPhone = "+38733456789",
            ContactEmail = "info@skylinecourt.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800",
            HasParking = false,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = false,
            HasCafeBar = false,
            HasWaterFountain = true,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue3);
        await _context.SaveChangesAsync();

        var cancellation3 = new CancellationPolicy
        {
            VenueId = venue3.Id,
            FreeUntil = DateTime.Now.AddDays(30),
            Fee = 30.0m
        };
        _context.CancellationPolicies.Add(cancellation3);
        await _context.SaveChangesAsync();

        var venue4 = new Venue
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
            VenueImageUrl = "https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = false,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = true,
            HasWaterFountain = true,
            HasSeatingArea = false
        };
        _context.Venues.Add(venue4);
        await _context.SaveChangesAsync();

        var venue5 = new Venue
        {
            Name = "Central 5-a-Side",
            Location = "Sarajevo",
            Address = "Grbavica, Sarajevo 71000",
            SportType = "Football",
            SurfaceType = "Artificial Turf",
            Description = "Perfect 5-a-side football venue in the heart of the city.",
            PricePerHour = 40.00m,
            AvailableSlots = 16,
            ContactPhone = "+38733789456",
            ContactEmail = "info@central5.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = false,
            HasCafeBar = false,
            HasWaterFountain = true,
            HasSeatingArea = false
        };
        _context.Venues.Add(venue5);
        await _context.SaveChangesAsync();

        var discount5 = new Discount
        {
            VenueId = venue5.Id,
            Percentage = 10.0m,
            ForBookings = 3
        };
        _context.Discounts.Add(discount5);
        await _context.SaveChangesAsync();

        var venue6 = new Venue
        {
            Name = "Grand Slam Tennis",
            Location = "Mostar",
            Address = "Sjeverni Logor, Mostar 88000",
            SportType = "Tennis",
            SurfaceType = "Clay",
            Description = "Professional tennis courts with clay and hard surfaces available.",
            PricePerHour = 25.00m,
            AvailableSlots = 14,
            ContactPhone = "+38736654321",
            ContactEmail = "info@grandslam.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800",
            HasParking = true,
            HasShowers = false,
            HasLighting = false,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = false,
            HasWaterFountain = false,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue6);
        await _context.SaveChangesAsync();

        var venues = new List<Venue> { venue1, venue2, venue3, venue4, venue5, venue6 };

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
                VenueId = venue1.Id,
                CourtId = courts[0].Id,
                BookingNumber = "BK2026011214510257779",
                BookingDate = DateTime.Parse("2026-01-12"),
                StartTime = DateTime.Parse("2026-01-12 16:00:00"),
                EndTime = DateTime.Parse("2026-01-12 17:00:00"),
                Duration = 1,
                NumberOfPlayers = 10,
                PricePerHour = 45.00m,
                SubtotalPrice = 45.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 5.00m,
                TotalPrice = 50.00m,
                Status = BookingStatus.Cancelled,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Parse("2026-01-11"),
                PaidAt = DateTime.Parse("2026-01-11"),
                CancelledAt = DateTime.Parse("2026-01-12")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue2.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue2.Id)?.Id,
                BookingNumber = "BK2026011214504102052",
                BookingDate = DateTime.Parse("2026-01-12"),
                StartTime = DateTime.Parse("2026-01-12 19:00:00"),
                EndTime = DateTime.Parse("2026-01-12 20:00:00"),
                Duration = 1,
                NumberOfPlayers = 4,
                PricePerHour = 50.00m,
                SubtotalPrice = 50.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 50.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Parse("2026-01-11")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue5.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue5.Id)?.Id,
                BookingNumber = "BK2026011213135761186",
                BookingDate = DateTime.Parse("2026-01-12"),
                StartTime = DateTime.Parse("2026-01-12 18:00:00"),
                EndTime = DateTime.Parse("2026-01-12 19:00:00"),
                Duration = 1,
                NumberOfPlayers = 10,
                PricePerHour = 40.00m,
                SubtotalPrice = 40.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 15.00m,
                Status = BookingStatus.Cancelled,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Parse("2026-01-10"),
                PaidAt = DateTime.Parse("2026-01-10"),
                CancelledAt = DateTime.Parse("2026-01-11")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue1.Id,
                CourtId = courts[1].Id,
                BookingNumber = "BK2026011211279575",
                BookingDate = DateTime.Parse("2026-01-12"),
                StartTime = DateTime.Parse("2026-01-12 18:00:00"),
                EndTime = DateTime.Parse("2026-01-12 20:00:00"),
                Duration = 2,
                NumberOfPlayers = 10,
                PricePerHour = 45.00m,
                SubtotalPrice = 90.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 45.00m,
                Status = BookingStatus.Cancelled,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Parse("2026-01-10"),
                PaidAt = DateTime.Parse("2026-01-10"),
                CancelledAt = DateTime.Parse("2026-01-11")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue2.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue2.Id)?.Id,
                BookingNumber = "BK2026011212371046570",
                BookingDate = DateTime.Parse("2026-01-12"),
                StartTime = DateTime.Parse("2026-01-12 17:00:00"),
                EndTime = DateTime.Parse("2026-01-12 18:00:00"),
                Duration = 1,
                NumberOfPlayers = 4,
                PricePerHour = 50.00m,
                SubtotalPrice = 50.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 50.00m,
                Status = BookingStatus.Confirmed,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Parse("2026-01-10"),
                ConfirmedAt = DateTime.Parse("2026-01-10"),
                PaidAt = DateTime.Parse("2026-01-10")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue1.Id,
                CourtId = courts[0].Id,
                BookingNumber = "BK2026011123051312337",
                BookingDate = DateTime.Parse("2026-01-12"),
                StartTime = DateTime.Parse("2026-01-12 11:00:00"),
                EndTime = DateTime.Parse("2026-01-12 12:00:00"),
                Duration = 1,
                NumberOfPlayers = 10,
                PricePerHour = 45.00m,
                SubtotalPrice = 45.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 45.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Parse("2026-01-10")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue2.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue2.Id)?.Id,
                BookingNumber = "BK2026011123052295568",
                BookingDate = DateTime.Parse("2026-01-13"),
                StartTime = DateTime.Parse("2026-01-13 11:00:00"),
                EndTime = DateTime.Parse("2026-01-13 12:00:00"),
                Duration = 1,
                NumberOfPlayers = 4,
                PricePerHour = 50.00m,
                SubtotalPrice = 50.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 50.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Parse("2026-01-10")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue2.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue2.Id)?.Id,
                BookingNumber = "BK2026011125544487023",
                BookingDate = DateTime.Parse("2026-01-11"),
                StartTime = DateTime.Parse("2026-01-11 12:00:00"),
                EndTime = DateTime.Parse("2026-01-11 13:00:00"),
                Duration = 1,
                NumberOfPlayers = 4,
                PricePerHour = 50.00m,
                SubtotalPrice = 50.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 50.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Parse("2026-01-10")
            }
        };
        _context.Bookings.AddRange(bookings);
        await _context.SaveChangesAsync();

        var reviews = new List<Review>
        {
            new Review
            {
                UserId = users[0].Id,
                VenueId = venue1.Id,
                Rating = 5,
                Comment = "Excellent venue! Great facilities and very well maintained.",
                CreatedAt = DateTime.Now.AddDays(-3)
            },
            new Review
            {
                UserId = users[2].Id,
                VenueId = venue1.Id,
                Rating = 5,
                Comment = "Perfect for evening games. Lighting is great!",
                CreatedAt = DateTime.Now.AddDays(-8)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venue2.Id,
                Rating = 5,
                Comment = "Best padel club in town! Professional service.",
                CreatedAt = DateTime.Now.AddDays(-2)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venue3.Id,
                Rating = 4,
                Comment = "Good basketball court, could use better parking.",
                CreatedAt = DateTime.Now.AddDays(-4)
            }
        };
        _context.Reviews.AddRange(reviews);
        await _context.SaveChangesAsync();

        var favorites = new List<UserFavoriteVenue>
        {
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venue1.Id, CreatedAt = DateTime.Now.AddDays(-10) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venue2.Id, CreatedAt = DateTime.Now.AddDays(-8) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venue3.Id, CreatedAt = DateTime.Now.AddDays(-5) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venue6.Id, CreatedAt = DateTime.Now.AddDays(-3) },
            new UserFavoriteVenue { UserId = users[0].Id, VenueId = venue5.Id, CreatedAt = DateTime.Now.AddDays(-1) },
        };
        _context.UserFavoriteVenues.AddRange(favorites);
        await _context.SaveChangesAsync();

        Console.WriteLine("Database seeded successfully!");
    }
}

