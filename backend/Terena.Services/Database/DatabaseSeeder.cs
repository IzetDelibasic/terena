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
            SurfaceType = "Artificial Turf",
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
            Name = "Arena Grbavica",
            Location = "Sarajevo",
            Address = "Grbavica, Sarajevo 71000",
            SportType = "Football",
            SurfaceType = "Artificial Turf",
            Description = "Premium 5-a-side and 7-a-side football venue in the heart of Sarajevo.",
            PricePerHour = 40.00m,
            AvailableSlots = 20,
            ContactPhone = "+38733789456",
            ContactEmail = "info@arenagrbavica.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = true,
            HasWaterFountain = true,
            HasSeatingArea = false
        };
        _context.Venues.Add(venue2);
        await _context.SaveChangesAsync();

        var cancellation2 = new CancellationPolicy
        {
            VenueId = venue2.Id,
            Fee = 30.0m
        };
        var discount2 = new Discount
        {
            VenueId = venue2.Id,
            Percentage = 15.0m,
            ForBookings = 4
        };
        _context.CancellationPolicies.Add(cancellation2);
        _context.Discounts.Add(discount2);
        await _context.SaveChangesAsync();

        var venue3 = new Venue
        {
            Name = "Skyline Basketball Arena",
            Location = "Sarajevo",
            Address = "Ilidza, Sarajevo 71000",
            SportType = "Basketball",
            SurfaceType = "Hardwood",
            Description = "Modern basketball courts with excellent facilities and city views.",
            PricePerHour = 35.00m,
            AvailableSlots = 15,
            ContactPhone = "+38733456789",
            ContactEmail = "info@skylinearena.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = false,
            HasWaterFountain = true,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue3);
        await _context.SaveChangesAsync();

        var cancellation3 = new CancellationPolicy
        {
            VenueId = venue3.Id,
            Fee = 25.0m
        };
        var discount3 = new Discount
        {
            VenueId = venue3.Id,
            Percentage = 20.0m,
            ForBookings = 5
        };
        _context.CancellationPolicies.Add(cancellation3);
        _context.Discounts.Add(discount3);
        await _context.SaveChangesAsync();

        var venue4 = new Venue
        {
            Name = "Hoops Center Banja Luka",
            Location = "Banja Luka",
            Address = "Centar, Banja Luka 78000",
            SportType = "Basketball",
            SurfaceType = "Synthetic",
            Description = "Indoor basketball courts with professional equipment and coaching available.",
            PricePerHour = 30.00m,
            AvailableSlots = 12,
            ContactPhone = "+38751654321",
            ContactEmail = "info@hoopscenter.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = false,
            HasCafeBar = true,
            HasWaterFountain = true,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue4);
        await _context.SaveChangesAsync();

        var cancellation4 = new CancellationPolicy
        {
            VenueId = venue4.Id,
            Fee = 40.0m
        };
        _context.CancellationPolicies.Add(cancellation4);
        await _context.SaveChangesAsync();

        var venue5 = new Venue
        {
            Name = "Grand Slam Tennis Club",
            Location = "Mostar",
            Address = "Sjeverni Logor, Mostar 88000",
            SportType = "Tennis",
            SurfaceType = "Clay",
            Description = "Professional tennis courts with clay and hard surfaces. Perfect for all skill levels.",
            PricePerHour = 25.00m,
            AvailableSlots = 16,
            ContactPhone = "+38736654321",
            ContactEmail = "info@grandslamtennis.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = true,
            HasWaterFountain = true,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue5);
        await _context.SaveChangesAsync();

        var cancellation5 = new CancellationPolicy
        {
            VenueId = venue5.Id,
            Fee = 20.0m
        };
        var discount5 = new Discount
        {
            VenueId = venue5.Id,
            Percentage = 12.0m,
            ForBookings = 3
        };
        _context.CancellationPolicies.Add(cancellation5);
        _context.Discounts.Add(discount5);
        await _context.SaveChangesAsync();

        var venue6 = new Venue
        {
            Name = "Ace Tennis Academy",
            Location = "Sarajevo",
            Address = "Otoka, Sarajevo 71000",
            SportType = "Tennis",
            SurfaceType = "Hard Court",
            Description = "State-of-the-art tennis facility with professional coaching and modern amenities.",
            PricePerHour = 28.00m,
            AvailableSlots = 14,
            ContactPhone = "+38733987654",
            ContactEmail = "info@acetennisacademy.ba",
            VenueImageUrl = "https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?w=800",
            HasParking = true,
            HasShowers = true,
            HasLighting = true,
            HasChangingRooms = true,
            HasEquipmentRental = true,
            HasCafeBar = false,
            HasWaterFountain = true,
            HasSeatingArea = true
        };
        _context.Venues.Add(venue6);
        await _context.SaveChangesAsync();

        var cancellation6 = new CancellationPolicy
        {
            VenueId = venue6.Id,
            Fee = 35.0m
        };
        var discount6 = new Discount
        {
            VenueId = venue6.Id,
            Percentage = 8.0m,
            ForBookings = 2
        };
        _context.CancellationPolicies.Add(cancellation6);
        _context.Discounts.Add(discount6);
        await _context.SaveChangesAsync();

        var venues = new List<Venue> { venue1, venue2, venue3, venue4, venue5, venue6 };

        var courts = new List<Court>();
        foreach (var venue in venues)
        {
            if (venue.SportType == "Football")
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
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Court 2",
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
                    Name = "Court 1",
                    CourtType = "Singles/Doubles",
                    MaxCapacity = "4",
                    IsAvailable = true
                });
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Court 2",
                    CourtType = "Singles/Doubles",
                    MaxCapacity = "4",
                    IsAvailable = true
                });
                courts.Add(new Court
                {
                    VenueId = venue.Id,
                    Name = "Court 3",
                    CourtType = "Singles/Doubles",
                    MaxCapacity = "4",
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
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue1.Id)?.Id,
                BookingNumber = "BK2026011214510257779",
                BookingDate = DateTime.Parse("2026-01-15"),
                StartTime = DateTime.Parse("2026-01-15 18:00:00"),
                EndTime = DateTime.Parse("2026-01-15 21:00:00"),
                Duration = 3,
                NumberOfPlayers = 10,
                PricePerHour = 45.00m,
                SubtotalPrice = 135.00m,
                DiscountAmount = 13.50m,
                DiscountPercentage = 10,
                ServiceFee = 0,
                TotalPrice = 121.50m,
                Status = BookingStatus.Confirmed,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Parse("2026-01-12"),
                PaidAt = DateTime.Parse("2026-01-12"),
                ConfirmedAt = DateTime.Parse("2026-01-12")
            },
            new Booking
            {
                UserId = users[2].Id,
                VenueId = venue3.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue3.Id)?.Id,
                BookingNumber = "BK2026011214504102052",
                BookingDate = DateTime.Parse("2026-01-16"),
                StartTime = DateTime.Parse("2026-01-16 19:00:00"),
                EndTime = DateTime.Parse("2026-01-16 20:00:00"),
                Duration = 1,
                NumberOfPlayers = 8,
                PricePerHour = 35.00m,
                SubtotalPrice = 35.00m,
                DiscountAmount = 0,
                DiscountPercentage = 0,
                ServiceFee = 0,
                TotalPrice = 35.00m,
                Status = BookingStatus.Pending,
                PaymentStatus = PaymentStatus.Pending,
                CreatedAt = DateTime.Parse("2026-01-13")
            },
            new Booking
            {
                UserId = users[0].Id,
                VenueId = venue5.Id,
                CourtId = courts.FirstOrDefault(c => c.VenueId == venue5.Id)?.Id,
                BookingNumber = "BK2026011213135761186",
                BookingDate = DateTime.Parse("2026-01-14"),
                StartTime = DateTime.Parse("2026-01-14 17:00:00"),
                EndTime = DateTime.Parse("2026-01-14 20:00:00"),
                Duration = 3,
                NumberOfPlayers = 4,
                PricePerHour = 25.00m,
                SubtotalPrice = 75.00m,
                DiscountAmount = 9.00m,
                DiscountPercentage = 12,
                ServiceFee = 0,
                TotalPrice = 66.00m,
                Status = BookingStatus.Confirmed,
                PaymentStatus = PaymentStatus.Paid,
                CreatedAt = DateTime.Parse("2026-01-11"),
                PaidAt = DateTime.Parse("2026-01-11"),
                ConfirmedAt = DateTime.Parse("2026-01-11")
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
                Comment = "Excellent football venue! Great facilities and very well maintained.",
                CreatedAt = DateTime.Now.AddDays(-3)
            },
            new Review
            {
                UserId = users[2].Id,
                VenueId = venue1.Id,
                Rating = 5,
                Comment = "Perfect for evening games. Lighting is amazing!",
                CreatedAt = DateTime.Now.AddDays(-8)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venue2.Id,
                Rating = 5,
                Comment = "Best football venue in Sarajevo! Great atmosphere.",
                CreatedAt = DateTime.Now.AddDays(-2)
            },
            new Review
            {
                UserId = users[2].Id,
                VenueId = venue3.Id,
                Rating = 5,
                Comment = "Amazing basketball court! Top-notch facilities.",
                CreatedAt = DateTime.Now.AddDays(-4)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venue4.Id,
                Rating = 4,
                Comment = "Good basketball court in Banja Luka. Nice staff.",
                CreatedAt = DateTime.Now.AddDays(-6)
            },
            new Review
            {
                UserId = users[2].Id,
                VenueId = venue5.Id,
                Rating = 5,
                Comment = "Best tennis club! Clay courts are excellent.",
                CreatedAt = DateTime.Now.AddDays(-5)
            },
            new Review
            {
                UserId = users[0].Id,
                VenueId = venue6.Id,
                Rating = 5,
                Comment = "Professional tennis academy. Highly recommended!",
                CreatedAt = DateTime.Now.AddDays(-7)
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

