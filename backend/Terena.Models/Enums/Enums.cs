namespace Terena.Models.Enums
{
    public enum UserStatus
    {
        Active,
        Blocked
    }

    public enum UserRole
    {
        Admin,
        Customer
    }

    public enum BookingStatus
    {
        Pending,
        Accepted,
        Confirmed,
        Completed,
        Cancelled,
        Expired
    }

    public enum PaymentStatus
    {
        Pending,
        Paid,
        Refunded,
        PartiallyRefunded
    }
}
