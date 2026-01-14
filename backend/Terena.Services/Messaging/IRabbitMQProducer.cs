namespace Terena.Services.Messaging;

public interface IRabbitMQProducer
{
    void SendMessage<T>(T message, string queueName);
}
