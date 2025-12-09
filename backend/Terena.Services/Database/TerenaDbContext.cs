using Microsoft.EntityFrameworkCore;

namespace Terena.Services.Database
{
    public class TerenaDbContext : DbContext
    {
        public TerenaDbContext(DbContextOptions<TerenaDbContext> options) : base(options) { }

        public DbSet<Venue> Venues { get; set; }
        public DbSet<VenueAmenity> VenueAmenities { get; set; }
        public DbSet<OperatingHour> OperatingHours { get; set; }
        public DbSet<CancellationPolicy> CancellationPolicies { get; set; }
        public DbSet<Discount> Discounts { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Court> Courts { get; set; }
        public DbSet<Booking> Bookings { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Venue>()
                .HasMany(v => v.Amenities)
                .WithOne()
                .HasForeignKey(a => a.VenueId);

            modelBuilder.Entity<Venue>()
                .HasMany(v => v.OperatingHours)
                .WithOne(o => o.Venue)
                .HasForeignKey(o => o.VenueId);

            modelBuilder.Entity<Venue>()
                .HasOne(v => v.CancellationPolicy)
                .WithOne(c => c.Venue)
                .HasForeignKey<CancellationPolicy>(c => c.VenueId)
                .IsRequired(false);

            modelBuilder.Entity<Venue>()
                .HasOne(v => v.Discount)
                .WithOne(d => d.Venue)
                .HasForeignKey<Discount>(d => d.VenueId)
                .IsRequired(false);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<Court>()
                .HasOne(c => c.Venue)
                .WithMany(v => v.Courts)
                .HasForeignKey(c => c.VenueId);

            modelBuilder.Entity<Booking>()
                .HasOne(b => b.User)
                .WithMany(u => u.Bookings)
                .HasForeignKey(b => b.UserId);

            modelBuilder.Entity<Booking>()
                .HasOne(b => b.Venue)
                .WithMany(v => v.Bookings)
                .HasForeignKey(b => b.VenueId);

            modelBuilder.Entity<Booking>()
                .HasOne(b => b.Court)
                .WithMany(c => c.Bookings)
                .HasForeignKey(b => b.CourtId)
                .IsRequired(false);

            modelBuilder.Entity<Booking>()
                .HasIndex(b => b.BookingNumber)
                .IsUnique();
        }
    }
}
