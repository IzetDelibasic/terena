using Microsoft.Extensions.Hosting;
using Terena.Services.Interfaces;
using Terena.Services.Messaging;

namespace Terena.API.BackgroundServices;

public class EmailConsumerService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private RabbitMQConsumer? _consumer;

    public EmailConsumerService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Console.WriteLine("[EmailConsumerService] Starting email consumer background service...");

        await Task.Delay(2000, stoppingToken);

        try
        {
            using var scope = _serviceProvider.CreateScope();
            var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

            _consumer = new RabbitMQConsumer(emailService);
            _consumer.StartConsuming();

            Console.WriteLine("[EmailConsumerService] Email consumer service started successfully");

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(1000, stoppingToken);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[EmailConsumerService] Error: {ex.Message}");
            Console.WriteLine($"[EmailConsumerService] Note: Make sure RabbitMQ is running on localhost:5672");
        }
    }

    public override Task StopAsync(CancellationToken cancellationToken)
    {
        Console.WriteLine("[EmailConsumerService] Stopping email consumer service...");
        _consumer?.StopConsuming();
        return base.StopAsync(cancellationToken);
    }
}
