using System;
using System.Threading.Tasks;
using Stripe;

namespace Terena.Services
{
    public class PaymentService
    {
        public PaymentService()
        {
            var stripeSecretKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");
            
            if (string.IsNullOrEmpty(stripeSecretKey))
            {
                throw new InvalidOperationException(
                    "STRIPE_SECRET_KEY environment variable is not set. " +
                    "Please add STRIPE_SECRET_KEY=your_key to the .env file in Terena.API folder.");
            }
            
            StripeConfiguration.ApiKey = stripeSecretKey;
        }

        public async Task<PaymentIntent> CreatePaymentIntentAsync(decimal amount, string currency = "eur", string description = null)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(amount * 100), 
                Currency = currency,
                Description = description,
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true,
                },
            };

            var service = new PaymentIntentService();
            return await service.CreateAsync(options);
        }

        public async Task<PaymentIntent> ConfirmPaymentIntentAsync(string paymentIntentId)
        {
            var service = new PaymentIntentService();
            return await service.GetAsync(paymentIntentId);
        }

        public async Task<Refund> CreateRefundAsync(string chargeId, decimal? amount = null)
        {
            var options = new RefundCreateOptions
            {
                Charge = chargeId,
            };

            if (amount.HasValue)
            {
                options.Amount = (long)(amount.Value * 100);
            }

            var service = new RefundService();
            return await service.CreateAsync(options);
        }

        public async Task<PaymentIntent> CancelPaymentIntentAsync(string paymentIntentId)
        {
            var service = new PaymentIntentService();
            return await service.CancelAsync(paymentIntentId);
        }
    }
}
