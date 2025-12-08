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
                .HasForeignKey<CancellationPolicy>(c => c.VenueId);

            modelBuilder.Entity<Venue>()
                .HasOne(v => v.Discount)
                .WithOne(d => d.Venue)
                .HasForeignKey<Discount>(d => d.VenueId);
        }
    }
}
