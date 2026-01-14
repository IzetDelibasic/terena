using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Terena.Models.Messages;
using Terena.Services.Interfaces;

namespace Terena.Services.Messaging;

public class RabbitMQConsumer
{
    private readonly IEmailService _emailService;
    private IConnection? _connection;
    private IModel? _channel;

    private const string BOOKING_CONFIRMATION_QUEUE = "booking_confirmations";
    private const string BOOKING_CANCELLATION_QUEUE = "booking_cancellations";
    private const string BOOKING_REMINDER_QUEUE = "booking_reminders";

    public RabbitMQConsumer(IEmailService emailService)
    {
        _emailService = emailService;
    }

    public void StartConsuming()
    {
        try
        {
            var factory = new ConnectionFactory
            {
                HostName = "localhost",
                Port = 5672,
                UserName = "guest",
                Password = "guest",
                VirtualHost = "/"
            };

            _connection = factory.CreateConnection();
            _channel = _connection.CreateModel();

            _channel.QueueDeclare(
                queue: BOOKING_CONFIRMATION_QUEUE,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            _channel.QueueDeclare(
                queue: BOOKING_CANCELLATION_QUEUE,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            _channel.QueueDeclare(
                queue: BOOKING_REMINDER_QUEUE,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

            ConsumeBookingConfirmations();

            ConsumeBookingCancellations();

            ConsumeBookingReminders();

            Console.WriteLine("[RabbitMQConsumer] Started consuming messages from all queues");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[RabbitMQConsumer] Error starting consumer: {ex.Message}");
            throw;
        }
    }

    private void ConsumeBookingConfirmations()
    {
        if (_channel == null) return;

        var consumer = new EventingBasicConsumer(_channel);

        consumer.Received += async (model, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var json = Encoding.UTF8.GetString(body);
                var message = JsonSerializer.Deserialize<BookingConfirmationMessage>(json);

                if (message != null)
                {
                    Console.WriteLine($"[RabbitMQConsumer] Processing booking confirmation: {message.BookingNumber}");

                    await _emailService.SendBookingConfirmationEmailAsync(
                        message.UserEmail,
                        message.UserName,
                        message.BookingNumber,
                        message.VenueName,
                        message.BookingDate,
                        message.TimeSlot,
                        message.TotalPrice
                    );

                    _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
                    Console.WriteLine($"[RabbitMQConsumer] Successfully processed booking confirmation: {message.BookingNumber}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[RabbitMQConsumer] Error processing booking confirmation: {ex.Message}");
                _channel?.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(
            queue: BOOKING_CONFIRMATION_QUEUE,
            autoAck: false,
            consumer: consumer
        );
    }

    private void ConsumeBookingCancellations()
    {
        if (_channel == null) return;

        var consumer = new EventingBasicConsumer(_channel);

        consumer.Received += async (model, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var json = Encoding.UTF8.GetString(body);
                var message = JsonSerializer.Deserialize<BookingCancellationMessage>(json);

                if (message != null)
                {
                    Console.WriteLine($"[RabbitMQConsumer] Processing booking cancellation: {message.BookingNumber}");

                    await _emailService.SendBookingCancellationEmailAsync(
                        message.UserEmail,
                        message.UserName,
                        message.BookingNumber,
                        message.VenueName,
                        message.Reason
                    );

                    _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
                    Console.WriteLine($"[RabbitMQConsumer] Successfully processed booking cancellation: {message.BookingNumber}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[RabbitMQConsumer] Error processing booking cancellation: {ex.Message}");
                _channel?.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(
            queue: BOOKING_CANCELLATION_QUEUE,
            autoAck: false,
            consumer: consumer
        );
    }

    private void ConsumeBookingReminders()
    {
        if (_channel == null) return;

        var consumer = new EventingBasicConsumer(_channel);

        consumer.Received += async (model, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var json = Encoding.UTF8.GetString(body);
                var message = JsonSerializer.Deserialize<BookingReminderMessage>(json);

                if (message != null)
                {
                    Console.WriteLine($"[RabbitMQConsumer] Processing booking reminder: {message.BookingNumber}");

                    await _emailService.SendBookingReminderEmailAsync(
                        message.UserEmail,
                        message.UserName,
                        message.BookingNumber,
                        message.VenueName,
                        message.BookingDate,
                        message.TimeSlot
                    );

                    _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
                    Console.WriteLine($"[RabbitMQConsumer] Successfully processed booking reminder: {message.BookingNumber}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[RabbitMQConsumer] Error processing booking reminder: {ex.Message}");
                _channel?.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(
            queue: BOOKING_REMINDER_QUEUE,
            autoAck: false,
            consumer: consumer
        );
    }

    public void StopConsuming()
    {
        _channel?.Close();
        _connection?.Close();
        Console.WriteLine("[RabbitMQConsumer] Stopped consuming messages");
    }
}
