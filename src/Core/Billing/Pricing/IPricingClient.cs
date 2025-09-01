using Bit.Core.Billing.Enums;
using Bit.Core.Exceptions;
using Bit.Core.Models.StaticStore;
using Bit.Core.Utilities;

#nullable enable

namespace Bit.Core.Billing.Pricing;

public interface IPricingClient
{
    /// <summary>
    /// Retrieve a Deepsafer plan by its <paramref name="planType"/>. If the feature flag 'use-pricing-service' is enabled,
    /// this will trigger a request to the Deepsafer Pricing Service. Otherwise, it will use the existing <see cref="StaticStore"/>.
    /// </summary>
    /// <param name="planType">The type of plan to retrieve.</param>
    /// <returns>A Deepsafer <see cref="Plan"/> record or null in the case the plan could not be found or the method was executed from a self-hosted instance.</returns>
    /// <exception cref="BillingException">Thrown when the request to the Pricing Service fails unexpectedly.</exception>
    Task<Plan?> GetPlan(PlanType planType);

    /// <summary>
    /// Retrieve a Deepsafer plan by its <paramref name="planType"/>. If the feature flag 'use-pricing-service' is enabled,
    /// this will trigger a request to the Deepsafer Pricing Service. Otherwise, it will use the existing <see cref="StaticStore"/>.
    /// </summary>
    /// <param name="planType">The type of plan to retrieve.</param>
    /// <returns>A Deepsafer <see cref="Plan"/> record.</returns>
    /// <exception cref="NotFoundException">Thrown when the <see cref="Plan"/> for the provided <paramref name="planType"/> could not be found or the method was executed from a self-hosted instance.</exception>
    /// <exception cref="BillingException">Thrown when the request to the Pricing Service fails unexpectedly.</exception>
    Task<Plan> GetPlanOrThrow(PlanType planType);

    /// <summary>
    /// Retrieve all the Deepsafer plans. If the feature flag 'use-pricing-service' is enabled,
    /// this will trigger a request to the Deepsafer Pricing Service. Otherwise, it will use the existing <see cref="StaticStore"/>.
    /// </summary>
    /// <returns>A list of Deepsafer <see cref="Plan"/> records or an empty list in the case the method is executed from a self-hosted instance.</returns>
    /// <exception cref="BillingException">Thrown when the request to the Pricing Service fails unexpectedly.</exception>
    Task<List<Plan>> ListPlans();
}
