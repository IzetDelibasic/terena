using System;
using System.Threading.Tasks;
using Stripe;

namespace Terena.Services
{
    public class PaymentService
    {
        private const string StripeSecretKey = "sk_test_51QcVg0RrsKyZUC4iYsHfn7gp6YBrz9n9xYhJ1kXUZnJp6aP3vQP4k0Ij8MwX8bXJ0n8jX7";
        
        public PaymentService()
        {
            StripeConfiguration.ApiKey = StripeSecretKey;
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
