using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using System.Collections.Generic;
using Bella.Subscriber.Models;
using Bella.Subscriber.Interfaces;
using System.Net.Sockets;
using System.Net;

namespace Bella.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // Check internet connectivity to smtp.gmail.com
            try
            {
                var addresses = await Dns.GetHostAddressesAsync("smtp.gmail.com");
                _logger.LogInformation($"smtp.gmail.com resolved to: {string.Join(", ", addresses.Select(a => a.ToString()))}");
                using (var client = new TcpClient())
                {
                    var connectTask = client.ConnectAsync("smtp.gmail.com", 587);
                    var timeoutTask = Task.Delay(5000, stoppingToken);
                    var completed = await Task.WhenAny(connectTask, timeoutTask);
                    if (completed == connectTask && client.Connected)
                    {
                        _logger.LogInformation("Successfully connected to smtp.gmail.com:587");
                    }
                    else
                    {
                        _logger.LogError("Failed to connect to smtp.gmail.com:587 (timeout or error)");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Internet connectivity check failed: {ex.Message}");
            }

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to appointment notifications
                        bus.PubSub.Subscribe<AppointmentNotification>("Appointment_Notifications", HandleAppointmentMessage);
                        
                        // Subscribe to appointment cancellation notifications
                        bus.PubSub.Subscribe<AppointmentCancellationNotification>("Appointment_Cancellation_Notifications", HandleAppointmentCancellationMessage);

                        _logger.LogInformation("Notification service is active and awaiting appointment events.");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                }
            }
        }

        private async Task HandleAppointmentMessage(AppointmentNotification notification)
        {
            var appointment = notification.Appointment;

            if (string.IsNullOrWhiteSpace(appointment.HairdresserEmail))
            {
                _logger.LogWarning("No hairdresser email provided in the appointment notification");
                return;
            }

            var subject = $"New Appointment Request - {appointment.UserFullName} - {appointment.AppointmentDate:MMM dd, yyyy 'at' HH:mm}";
            var htmlMessage = GenerateAppointmentEmailHtml(appointment);

            try
            {
                await _emailSender.SendEmailAsync(appointment.HairdresserEmail, subject, htmlMessage, isHtml: true);
                _logger.LogInformation($"Appointment notification sent to hairdresser: {appointment.HairdresserEmail}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send appointment email to {appointment.HairdresserEmail}: {ex.Message}");
            }
        }

        private string GenerateAppointmentEmailHtml(AppointmentNotificationDto appointment)
        {
            var servicesList = new List<string>();
            var totalPrice = 0m;

            if (!string.IsNullOrEmpty(appointment.HairstyleName))
            {
                servicesList.Add($"<li><strong>Hairstyle:</strong> {appointment.HairstyleName} - ${appointment.HairstylePrice:F2}</li>");
                totalPrice += appointment.HairstylePrice ?? 0;
            }

            if (!string.IsNullOrEmpty(appointment.FacialHairName))
            {
                servicesList.Add($"<li><strong>Facial Hair:</strong> {appointment.FacialHairName} - ${appointment.FacialHairPrice:F2}</li>");
                totalPrice += appointment.FacialHairPrice ?? 0;
            }

            if (!string.IsNullOrEmpty(appointment.DyingName))
            {
                var colorDisplay = !string.IsNullOrEmpty(appointment.DyingHexCode) 
                    ? $"<span style='display: inline-block; width: 20px; height: 20px; background-color: {appointment.DyingHexCode}; border: 1px solid #ccc; border-radius: 3px; vertical-align: middle; margin-left: 8px;' title='{appointment.DyingHexCode}'></span>"
                    : "";
                servicesList.Add($"<li><strong>Hair Dye:</strong> {appointment.DyingName} {colorDisplay} - $10.00</li>");
                totalPrice += 10m;
            }

            var servicesHtml = servicesList.Any() ? string.Join("", servicesList) : "<li><em>No services specified</em></li>";

            var phoneDisplay = !string.IsNullOrEmpty(appointment.UserPhoneNumber) 
                ? $"<p style='margin: 8px 0; color: #555;'><strong>Phone:</strong> {appointment.UserPhoneNumber}</p>"
                : "<p style='margin: 8px 0; color: #999;'><em>Phone number not provided</em></p>";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>New Appointment Request</title>
</head>
<body style='margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, ""Segoe UI"", Roboto, ""Helvetica Neue"", Arial, sans-serif; background-color: #f5f5f5;'>
    <table role='presentation' style='width: 100%; border-collapse: collapse; background-color: #f5f5f5; padding: 20px;'>
        <tr>
            <td align='center'>
                <table role='presentation' style='max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); overflow: hidden;'>
                    <!-- Header -->
                    <tr>
                        <td style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center;'>
                            <h1 style='margin: 0; color: #ffffff; font-size: 28px; font-weight: 600; letter-spacing: -0.5px;'>✨ New Appointment Request</h1>
                            <p style='margin: 10px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 16px;'>You have a new booking request</p>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style='padding: 40px 30px;'>
                            <!-- Client Information -->
                            <div style='background-color: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; border-radius: 8px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 15px 0; color: #333; font-size: 20px; font-weight: 600;'>👤 Client Information</h2>
                                <p style='margin: 8px 0; color: #555; font-size: 16px;'><strong>Name:</strong> {appointment.UserFullName}</p>
                                <p style='margin: 8px 0; color: #555; font-size: 16px;'><strong>Email:</strong> <a href='mailto:{appointment.UserEmail}' style='color: #667eea; text-decoration: none;'>{appointment.UserEmail}</a></p>
                                {phoneDisplay}
                            </div>

                            <!-- Appointment Details -->
                            <div style='background-color: #fff; border: 2px solid #e9ecef; border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 20px 0; color: #333; font-size: 20px; font-weight: 600;'>📅 Appointment Details</h2>
                                
                                <div style='display: flex; align-items: center; margin-bottom: 15px; padding: 15px; background-color: #f8f9fa; border-radius: 6px;'>
                                    <div style='flex: 1;'>
                                        <p style='margin: 0; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;'>Date & Time</p>
                                        <p style='margin: 5px 0 0 0; color: #333; font-size: 22px; font-weight: 600;'>{appointment.AppointmentDate:dddd, MMMM dd, yyyy}</p>
                                        <p style='margin: 5px 0 0 0; color: #667eea; font-size: 18px; font-weight: 500;'>{appointment.AppointmentDate:HH:mm} ({appointment.AppointmentDate:tt})</p>
                                    </div>
                                </div>

                                <div style='display: flex; align-items: center; margin-bottom: 15px; padding: 15px; background-color: #f8f9fa; border-radius: 6px;'>
                                    <div style='flex: 1;'>
                                        <p style='margin: 0; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;'>Status</p>
                                        <p style='margin: 5px 0 0 0; color: #333; font-size: 18px; font-weight: 600;'>{appointment.StatusName}</p>
                                    </div>
                                </div>

                                <div style='display: flex; align-items: center; padding: 15px; background-color: #f8f9fa; border-radius: 6px;'>
                                    <div style='flex: 1;'>
                                        <p style='margin: 0; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;'>Appointment ID</p>
                                        <p style='margin: 5px 0 0 0; color: #333; font-size: 18px; font-weight: 600;'>#{appointment.AppointmentId}</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Services -->
                            <div style='background-color: #fff; border: 2px solid #e9ecef; border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 20px 0; color: #333; font-size: 20px; font-weight: 600;'>💇 Services Requested</h2>
                                <ul style='margin: 0; padding-left: 20px; color: #555; font-size: 16px; line-height: 1.8;'>
                                    {servicesHtml}
                                </ul>
                            </div>

                            <!-- Pricing -->
                            <div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 15px 0; color: #ffffff; font-size: 20px; font-weight: 600;'>💰 Total Price</h2>
                                <p style='margin: 0; color: #ffffff; font-size: 36px; font-weight: 700;'>${appointment.FinalPrice:F2}</p>
                            </div>

                            <!-- Action Button -->
                            <div style='text-align: center; margin-top: 30px;'>
                                <p style='margin: 0 0 20px 0; color: #666; font-size: 14px; line-height: 1.6;'>
                                    Please review this appointment request and confirm or make any necessary adjustments in your system.
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style='background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;'>
                            <p style='margin: 0; color: #999; font-size: 14px; line-height: 1.6;'>
                                This is an automated notification from <strong>Bella</strong> Hair Salon Management System.<br>
                                Please do not reply to this email.
                            </p>
                            <p style='margin: 15px 0 0 0; color: #bbb; font-size: 12px;'>
                                © {DateTime.Now.Year} Bella. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }

        private async Task HandleAppointmentCancellationMessage(AppointmentCancellationNotification notification)
        {
            var appointment = notification.Appointment;

            if (string.IsNullOrWhiteSpace(appointment.HairdresserEmail))
            {
                _logger.LogWarning("No hairdresser email provided in the appointment cancellation notification");
                return;
            }

            var subject = $"Appointment Cancelled - {appointment.UserFullName} - {appointment.AppointmentDate:MMM dd, yyyy 'at' HH:mm}";
            var htmlMessage = GenerateCancellationEmailHtml(appointment);

            try
            {
                await _emailSender.SendEmailAsync(appointment.HairdresserEmail, subject, htmlMessage, isHtml: true);
                _logger.LogInformation($"Appointment cancellation notification sent to hairdresser: {appointment.HairdresserEmail}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send appointment cancellation email to {appointment.HairdresserEmail}: {ex.Message}");
            }
        }

        private string GenerateCancellationEmailHtml(AppointmentNotificationDto appointment)
        {
            var servicesList = new List<string>();

            if (!string.IsNullOrEmpty(appointment.HairstyleName))
            {
                servicesList.Add($"<li><strong>Hairstyle:</strong> {appointment.HairstyleName}</li>");
            }

            if (!string.IsNullOrEmpty(appointment.FacialHairName))
            {
                servicesList.Add($"<li><strong>Facial Hair:</strong> {appointment.FacialHairName}</li>");
            }

            if (!string.IsNullOrEmpty(appointment.DyingName))
            {
                var colorDisplay = !string.IsNullOrEmpty(appointment.DyingHexCode) 
                    ? $"<span style='display: inline-block; width: 20px; height: 20px; background-color: {appointment.DyingHexCode}; border: 1px solid #ccc; border-radius: 3px; vertical-align: middle; margin-left: 8px;' title='{appointment.DyingHexCode}'></span>"
                    : "";
                servicesList.Add($"<li><strong>Hair Dye:</strong> {appointment.DyingName} {colorDisplay}</li>");
            }

            var servicesHtml = servicesList.Any() ? string.Join("", servicesList) : "<li><em>No services were specified</em></li>";

            var phoneDisplay = !string.IsNullOrEmpty(appointment.UserPhoneNumber) 
                ? $"<p style='margin: 8px 0; color: #555;'><strong>Phone:</strong> {appointment.UserPhoneNumber}</p>"
                : "<p style='margin: 8px 0; color: #999;'><em>Phone number not provided</em></p>";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Appointment Cancelled</title>
</head>
<body style='margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, ""Segoe UI"", Roboto, ""Helvetica Neue"", Arial, sans-serif; background-color: #f5f5f5;'>
    <table role='presentation' style='width: 100%; border-collapse: collapse; background-color: #f5f5f5; padding: 20px;'>
        <tr>
            <td align='center'>
                <table role='presentation' style='max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); overflow: hidden;'>
                    <!-- Header -->
                    <tr>
                        <td style='background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); padding: 40px 30px; text-align: center;'>
                            <h1 style='margin: 0; color: #ffffff; font-size: 28px; font-weight: 600; letter-spacing: -0.5px;'>❌ Appointment Cancelled</h1>
                            <p style='margin: 10px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 16px;'>An appointment has been cancelled</p>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style='padding: 40px 30px;'>
                            <!-- Client Information -->
                            <div style='background-color: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; border-radius: 8px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 15px 0; color: #333; font-size: 20px; font-weight: 600;'>👤 Client Information</h2>
                                <p style='margin: 8px 0; color: #555; font-size: 16px;'><strong>Name:</strong> {appointment.UserFullName}</p>
                                <p style='margin: 8px 0; color: #555; font-size: 16px;'><strong>Email:</strong> <a href='mailto:{appointment.UserEmail}' style='color: #667eea; text-decoration: none;'>{appointment.UserEmail}</a></p>
                                {phoneDisplay}
                            </div>

                            <!-- Appointment Details -->
                            <div style='background-color: #fff; border: 2px solid #e9ecef; border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 20px 0; color: #333; font-size: 20px; font-weight: 600;'>📅 Appointment Details</h2>
                                
                                <div style='display: flex; align-items: center; margin-bottom: 15px; padding: 15px; background-color: #f8f9fa; border-radius: 6px;'>
                                    <div style='flex: 1;'>
                                        <p style='margin: 0; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;'>Date & Time</p>
                                        <p style='margin: 5px 0 0 0; color: #333; font-size: 22px; font-weight: 600;'>{appointment.AppointmentDate:dddd, MMMM dd, yyyy}</p>
                                        <p style='margin: 5px 0 0 0; color: #667eea; font-size: 18px; font-weight: 500;'>{appointment.AppointmentDate:HH:mm} ({appointment.AppointmentDate:tt})</p>
                                    </div>
                                </div>

                                <div style='display: flex; align-items: center; margin-bottom: 15px; padding: 15px; background-color: #fff3cd; border-radius: 6px; border-left: 4px solid #dc3545;'>
                                    <div style='flex: 1;'>
                                        <p style='margin: 0; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;'>Status</p>
                                        <p style='margin: 5px 0 0 0; color: #dc3545; font-size: 18px; font-weight: 600;'>{appointment.StatusName}</p>
                                    </div>
                                </div>

                                <div style='display: flex; align-items: center; padding: 15px; background-color: #f8f9fa; border-radius: 6px;'>
                                    <div style='flex: 1;'>
                                        <p style='margin: 0; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;'>Appointment ID</p>
                                        <p style='margin: 5px 0 0 0; color: #333; font-size: 18px; font-weight: 600;'>#{appointment.AppointmentId}</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Services -->
                            <div style='background-color: #fff; border: 2px solid #e9ecef; border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 20px 0; color: #333; font-size: 20px; font-weight: 600;'>💇 Cancelled Services</h2>
                                <ul style='margin: 0; padding-left: 20px; color: #555; font-size: 16px; line-height: 1.8;'>
                                    {servicesHtml}
                                </ul>
                            </div>

                            <!-- Pricing -->
                            <div style='background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%); border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 15px 0; color: #ffffff; font-size: 20px; font-weight: 600;'>💰 Original Price</h2>
                                <p style='margin: 0; color: #ffffff; font-size: 36px; font-weight: 700;'>${appointment.FinalPrice:F2}</p>
                            </div>

                            <!-- Cancellation Notice -->
                            <div style='background-color: #fff3cd; border: 2px solid #ffc107; border-radius: 8px; padding: 25px; margin-bottom: 30px;'>
                                <h2 style='margin: 0 0 15px 0; color: #856404; font-size: 20px; font-weight: 600;'>⚠️ Important Notice</h2>
                                <p style='margin: 0; color: #856404; font-size: 16px; line-height: 1.6;'>
                                    This appointment has been cancelled. The time slot is now available for other bookings. 
                                    Please update your schedule accordingly.
                                </p>
                            </div>

                            <!-- Action Button -->
                            <div style='text-align: center; margin-top: 30px;'>
                                <p style='margin: 0 0 20px 0; color: #666; font-size: 14px; line-height: 1.6;'>
                                    This cancellation has been automatically processed in the system.
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style='background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;'>
                            <p style='margin: 0; color: #999; font-size: 14px; line-height: 1.6;'>
                                This is an automated notification from <strong>Bella</strong> Hair Salon Management System.<br>
                                Please do not reply to this email.
                            </p>
                            <p style='margin: 15px 0 0 0; color: #bbb; font-size: 12px;'>
                                © {DateTime.Now.Year} Bella. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }
    }
}