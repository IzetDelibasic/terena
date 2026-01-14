using System.Net;
using System.Net.Mail;
using System.Reflection;
using Terena.Services.Interfaces;

namespace Terena.Services;

public class EmailService : IEmailService
{
    private readonly string _smtpHost;
    private readonly int _smtpPort;
    private readonly string _smtpUsername;
    private readonly string _smtpPassword;
    private readonly string _fromEmail;
    private readonly string _fromName;
    private readonly bool _isConfigured;

    public EmailService()
    {
        _smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST") ?? "smtp.gmail.com";
        _smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "587");
        _smtpUsername = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "";
        _smtpPassword = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "";
        _fromEmail = Environment.GetEnvironmentVariable("FROM_EMAIL") ?? "noreply@terena.com";
        _fromName = Environment.GetEnvironmentVariable("FROM_NAME") ?? "Terena Platform";

        _isConfigured = !string.IsNullOrEmpty(_smtpUsername) && !string.IsNullOrEmpty(_smtpPassword);

        if (!_isConfigured)
        {
            Console.WriteLine("[EmailService] SMTP credentials not configured. Emails will not be sent.");
            Console.WriteLine("[EmailService] Set SMTP_USERNAME and SMTP_PASSWORD environment variables to enable email notifications.");
        }
        else
        {
            Console.WriteLine($"[EmailService] ✓ SMTP configured successfully");
            Console.WriteLine($"[EmailService]   Host: {_smtpHost}:{_smtpPort}");
            Console.WriteLine($"[EmailService]   Username: {_smtpUsername}");
            Console.WriteLine($"[EmailService]   From: {_fromName} <{_fromEmail}>");
        }
    }

    public async Task SendBookingConfirmationEmailAsync(
        string toEmail,
        string userName,
        string bookingNumber,
        string venueName,
        DateTime bookingDate,
        string timeSlot,
        decimal totalPrice)
    {
        try
        {
            var subject = $"Booking Confirmation - {bookingNumber}";
            var body = $@"
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background: linear-gradient(135deg, #2E7D32 0%, #4CAF50 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                        .booking-details {{ background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #4CAF50; }}
                        .detail-row {{ display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }}
                        .label {{ font-weight: bold; color: #555; }}
                        .value {{ color: #333; }}
                        .total {{ font-size: 24px; font-weight: bold; color: #2E7D32; text-align: right; margin-top: 20px; }}
                        .footer {{ text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #777; font-size: 12px; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>🎉 Booking Confirmed!</h1>
                            <p>Your reservation has been successfully confirmed</p>
                        </div>
                        <div class='content'>
                            <p>Hi {userName},</p>
                            <p>Thank you for booking with Terena! Your reservation has been confirmed.</p>

                            <div class='booking-details'>
                                <h2 style='margin-top: 0; color: #2E7D32;'>Booking Details</h2>
                                <div class='detail-row'>
                                    <span class='label'>Booking Number:</span>
                                    <span class='value'>{bookingNumber}</span>
                                </div>
                                <div class='detail-row'>
                                    <span class='label'>Venue:</span>
                                    <span class='value'>{venueName}</span>
                                </div>
                                <div class='detail-row'>
                                    <span class='label'>Date:</span>
                                    <span class='value'>{bookingDate:dddd, dd MMMM yyyy}</span>
                                </div>
                                <div class='detail-row'>
                                    <span class='label'>Time:</span>
                                    <span class='value'>{timeSlot}</span>
                                </div>
                                <div class='total'>
                                    Total: {totalPrice:F2} BAM
                                </div>
                            </div>

                            <p><strong>What's next?</strong></p>
                            <ul>
                                <li>You will receive a reminder 24 hours before your booking</li>
                                <li>Please arrive 10 minutes before your scheduled time</li>
                                <li>Bring your booking confirmation number</li>
                            </ul>

                            <p>If you have any questions, feel free to contact us.</p>

                            <p>See you soon!<br>The Terena Team</p>
                        </div>
                        <div class='footer'>
                            <p>© 2026 Terena Platform. All rights reserved.</p>
                            <p>This is an automated email, please do not reply.</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            await SendEmailAsync(toEmail, subject, body);
        }
        catch (Exception ex)
        {
            // Email sending failed - silently handle
        }
    }

    public async Task SendBookingCancellationEmailAsync(
        string toEmail,
        string userName,
        string bookingNumber,
        string venueName,
        string reason)
    {
        try
        {
            var subject = $"Booking Cancelled - {bookingNumber}";
            var body = $@"
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background: linear-gradient(135deg, #D32F2F 0%, #F44336 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                        .booking-details {{ background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #F44336; }}
                        .footer {{ text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #777; font-size: 12px; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>❌ Booking Cancelled</h1>
                            <p>Your reservation has been cancelled</p>
                        </div>
                        <div class='content'>
                            <p>Hi {userName},</p>
                            <p>We're writing to confirm that your booking has been cancelled.</p>

                            <div class='booking-details'>
                                <h2 style='margin-top: 0; color: #D32F2F;'>Cancellation Details</h2>
                                <p><strong>Booking Number:</strong> {bookingNumber}</p>
                                <p><strong>Venue:</strong> {venueName}</p>
                                <p><strong>Reason:</strong> {reason}</p>
                            </div>

                            <p>If you believe this was done in error, please contact our support team immediately.</p>

                            <p>We hope to see you again soon!<br>The Terena Team</p>
                        </div>
                        <div class='footer'>
                            <p>© 2026 Terena Platform. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            await SendEmailAsync(toEmail, subject, body);
        }
        catch (Exception ex)
        {
            // Email sending failed - silently handle
        }
    }

    public async Task SendBookingReminderEmailAsync(
        string toEmail,
        string userName,
        string bookingNumber,
        string venueName,
        DateTime bookingDate,
        string timeSlot)
    {
        try
        {
            var subject = $"Reminder: Your booking tomorrow at {venueName}";
            var body = $@"
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background: linear-gradient(135deg, #F57C00 0%, #FF9800 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                        .booking-details {{ background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FF9800; }}
                        .footer {{ text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #777; font-size: 12px; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>⏰ Booking Reminder</h1>
                            <p>Your reservation is coming up!</p>
                        </div>
                        <div class='content'>
                            <p>Hi {userName},</p>
                            <p>This is a friendly reminder about your upcoming booking.</p>

                            <div class='booking-details'>
                                <h2 style='margin-top: 0; color: #F57C00;'>Booking Details</h2>
                                <p><strong>Booking Number:</strong> {bookingNumber}</p>
                                <p><strong>Venue:</strong> {venueName}</p>
                                <p><strong>Date:</strong> {bookingDate:dddd, dd MMMM yyyy}</p>
                                <p><strong>Time:</strong> {timeSlot}</p>
                            </div>

                            <p><strong>Important reminders:</strong></p>
                            <ul>
                                <li>Please arrive 10 minutes before your scheduled time</li>
                                <li>Bring your booking confirmation number</li>
                                <li>Check the weather if booking outdoor courts</li>
                            </ul>

                            <p>Looking forward to seeing you!<br>The Terena Team</p>
                        </div>
                        <div class='footer'>
                            <p>© 2026 Terena Platform. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            await SendEmailAsync(toEmail, subject, body);
        }
        catch (Exception ex)
        {
            // Email sending failed - silently handle
        }
    }

    private async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        if (!_isConfigured)
        {
            return;
        }

        try
        {
            using var client = new SmtpClient(_smtpHost, _smtpPort)
            {
                EnableSsl = true,
                Credentials = new NetworkCredential(_smtpUsername, _smtpPassword)
            };

            var mailMessage = new MailMessage
            {
                From = new MailAddress(_fromEmail, _fromName),
                Subject = subject,
                Body = body,
                IsBodyHtml = true
            };

            mailMessage.To.Add(toEmail);

            await client.SendMailAsync(mailMessage);
        }
        catch (Exception ex)
        {
            // SMTP error - silently handle
        }
    }
}
