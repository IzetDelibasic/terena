using Microsoft.EntityFrameworkCore;
using Terena.API.Filters;
using Terena.Services.Mapping;

DotNetEnv.Env.Load();

var builder = WebApplication.CreateBuilder(args);

RegisterMappings.Register();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<Terena.Services.Database.TerenaDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddScoped<Terena.Services.Interfaces.IVenueService, Terena.Services.VenueService>();
builder.Services.AddScoped<Terena.Services.Interfaces.IUserService, Terena.Services.UserService>();
builder.Services.AddScoped<Terena.Services.Interfaces.ICourtService, Terena.Services.CourtService>();
builder.Services.AddScoped<Terena.Services.Interfaces.IBookingService, Terena.Services.BookingService>();
builder.Services.AddScoped<Terena.Services.ReviewService>();
builder.Services.AddScoped<Terena.Services.FavoriteService>();
builder.Services.AddScoped<Terena.Services.PaymentService>();
builder.Services.AddScoped<Terena.Services.Interfaces.IRecommendationService, Terena.Services.RecommendationService>();
builder.Services.AddSingleton<Terena.Services.Messaging.IRabbitMQProducer, Terena.Services.Messaging.RabbitMQProducer>();
builder.Services.AddScoped<Terena.Services.Interfaces.INotificationService, Terena.Services.NotificationService>();
builder.Services.AddScoped<Terena.Services.Interfaces.IEmailService, Terena.Services.EmailService>();
builder.Services.AddHostedService<Terena.API.BackgroundServices.EmailConsumerService>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<Terena.Services.Database.TerenaDbContext>();

        await context.Database.MigrateAsync();

        var seeder = new Terena.Services.Database.ComprehensiveSeeder(context);
        await seeder.SeedAsync();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"An error occurred during database initialization: {ex.Message}");
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseRouting();
app.UseAuthorization();
app.MapControllers();

app.MapGet("/", context =>
{
    context.Response.Redirect("/swagger");
    return Task.CompletedTask;
});

app.Run();
