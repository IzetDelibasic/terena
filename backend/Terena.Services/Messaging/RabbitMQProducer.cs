using System.Text;
using System.Text.Json;
using RabbitMQ.Client;

namespace Terena.Services.Messaging;

public class RabbitMQProducer : IRabbitMQProducer
{
    private readonly IConnection? _connection;
    private readonly IModel? _channel;
    private readonly bool _isConnected;

    public RabbitMQProducer()
    {
        var factory = new ConnectionFactory
        {
            HostName = "localhost",
            Port = 5672,
            UserName = "guest",
            Password = "guest",
            VirtualHost = "/"
        };

        try
        {
            _connection = factory.CreateConnection();
            _channel = _connection.CreateModel();
            _isConnected = true;
            Console.WriteLine("[RabbitMQ] Successfully connected to RabbitMQ");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[RabbitMQ] Connection Error: {ex.Message}");
            Console.WriteLine("[RabbitMQ] Running without RabbitMQ - email notifications will be disabled");
            _isConnected = false;
        }
    }

    public void SendMessage<T>(T message, string queueName)
    {
        if (!_isConnected || _channel == null)
        {
            Console.WriteLine($"[RabbitMQ] Skipping message - RabbitMQ is not connected");
            return;
        }

        try
        {
            _channel.QueueDeclare(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            var json = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(json);

            var properties = _channel.CreateBasicProperties();
            properties.Persistent = true;
            properties.ContentType = "application/json";

            _channel.BasicPublish(
                exchange: string.Empty,
                routingKey: queueName,
                basicProperties: properties,
                body: body
            );
        }
        catch (Exception ex)
        {
            // Message send failed - silently handle
        }
    }

    public void Dispose()
    {
        _channel?.Close();
        _connection?.Close();
    }
}
