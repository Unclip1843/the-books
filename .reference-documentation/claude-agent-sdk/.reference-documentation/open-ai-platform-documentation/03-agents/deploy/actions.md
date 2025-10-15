# OpenAI Platform - Actions

**Source:** https://platform.openai.com/docs/guides/chatkit/actions
**Fetched:** 2025-10-11

## Overview

Actions allow agents to trigger external operations in response to user interactions or workflow conditions. They enable deep integration between your agent and business systems.

---

## Action Types

### 1. Button Actions

Triggered when users click buttons.

```typescript
// Define button with action
await chatkit.sendMessage({
  text: 'Would you like to proceed?',
  widgets: [
    {
      type: 'button',
      text: 'Confirm',
      action: 'confirm_order',
      metadata: { orderId: '12345' },
    },
  ],
});

// Handle action
chatkit.on('action:confirm_order', async (data) => {
  const orderId = data.metadata.orderId;
  await processOrder(orderId);
  await chatkit.sendMessage('Order confirmed!');
});
```

---

### 2. Form Actions

Triggered on form submission.

```typescript
await chatkit.sendMessage({
  widget: {
    type: 'form',
    action: 'submit_contact',
    fields: [
      { name: 'email', type: 'email', required: true },
      { name: 'message', type: 'textarea', required: true },
    ],
  },
});

chatkit.on('action:submit_contact', async (formData) => {
  await saveContact(formData);
  await chatkit.sendMessage('Thank you! We will contact you soon.');
});
```

---

### 3. Agent Actions

Triggered automatically by agent decisions.

```typescript
// Agent decides to create appointment
{
  type: 'agent_action',
  action: 'create_appointment',
  parameters: {
    date: '2025-10-15',
    time: '14:00',
    service: 'consultation',
  },
  requiresApproval: true,
}

// Handle agent action
chatkit.on('action:create_appointment', async (params) => {
  // Show confirmation to user
  await chatkit.sendMessage({
    text: 'Schedule appointment?',
    widgets: [
      { type: 'button', text: 'Confirm', action: 'approve_appointment' },
      { type: 'button', text: 'Cancel', action: 'cancel_appointment' },
    ],
  });
});
```

---

### 4. Scheduled Actions

Actions triggered at specific times.

```typescript
// Schedule reminder action
const action = {
  type: 'scheduled',
  action: 'send_reminder',
  scheduledFor: '2025-10-15T10:00:00Z',
  parameters: {
    userId: 'user_123',
    message: 'Appointment reminder',
  },
};

chatkit.scheduleAction(action);

// Handle when triggered
chatkit.on('action:send_reminder', async (params) => {
  await sendNotification(params.userId, params.message);
});
```

---

## Action Registration

### Register Actions

```typescript
// Register action handler
chatkit.registerAction('purchase_product', {
  // Validation
  validate: (params) => {
    if (!params.productId) {
      throw new Error('Product ID required');
    }
    if (!params.quantity || params.quantity < 1) {
      throw new Error('Valid quantity required');
    }
    return true;
  },

  // Execution
  execute: async (params) => {
    // Check inventory
    const available = await checkInventory(params.productId, params.quantity);
    if (!available) {
      return {
        success: false,
        error: 'Product out of stock',
      };
    }

    // Process purchase
    const order = await createOrder({
      productId: params.productId,
      quantity: params.quantity,
      userId: params.userId,
    });

    return {
      success: true,
      orderId: order.id,
    };
  },

  // Optional: Requires approval
  requiresApproval: (params) => {
    // Require approval for large orders
    return params.quantity > 10 || params.total > 1000;
  },

  // Optional: Rollback on error
  rollback: async (params, executionResult) => {
    if (executionResult.orderId) {
      await cancelOrder(executionResult.orderId);
    }
  },
});
```

---

## Action Workflows

### Multi-Step Actions

```typescript
// Step 1: Agent collects information
chatkit.on('action:book_appointment', async (params) => {
  // Validate date
  const available = await checkAvailability(params.date);

  if (!available) {
    await chatkit.sendMessage('That time is not available.');
    return;
  }

  // Step 2: Request confirmation
  await chatkit.sendMessage({
    text: `Confirm appointment for ${params.date}?`,
    widgets: [
      {
        type: 'button',
        text: 'Confirm',
        action: 'confirm_appointment',
        metadata: params,
      },
    ],
  });
});

// Step 3: Final confirmation
chatkit.on('action:confirm_appointment', async (data) => {
  const appointment = await createAppointment(data.metadata);

  await chatkit.sendMessage({
    text: 'Appointment booked!',
    widget: {
      type: 'card',
      title: 'Appointment Confirmed',
      description: `Date: ${appointment.date}\nTime: ${appointment.time}`,
      actions: [
        { label: 'Add to Calendar', action: 'add_calendar' },
        { label: 'Cancel', action: 'cancel_appointment' },
      ],
    },
  });
});
```

---

### Conditional Actions

```typescript
chatkit.on('action:submit_application', async (formData) => {
  // Validate application
  const validation = await validateApplication(formData);

  if (!validation.passed) {
    // Action: Request corrections
    await chatkit.sendMessage({
      text: 'Please correct the following:',
      widget: {
        type: 'list',
        items: validation.errors.map(err => ({
          title: err.field,
          subtitle: err.message,
        })),
      },
    });
    return;
  }

  // Check if requires manager approval
  if (formData.amount > 10000) {
    // Action: Request approval
    await requestManagerApproval(formData);
    await chatkit.sendMessage('Application sent for manager approval.');
  } else {
    // Action: Auto-approve
    await approveApplication(formData);
    await chatkit.sendMessage('Application approved!');
  }
});
```

---

## Action Approval

### Approval Workflow

```typescript
// Define action requiring approval
chatkit.registerAction('delete_account', {
  requiresApproval: true,

  // Request approval
  requestApproval: async (params, context) => {
    return {
      approvers: ['admin@example.com', 'manager@example.com'],
      message: `User ${context.userId} wants to delete their account`,
      timeout: 3600,  // 1 hour
    };
  },

  // Execute after approval
  execute: async (params, context, approval) => {
    if (approval.approved) {
      await deleteUserAccount(context.userId);
      return { success: true };
    } else {
      return {
        success: false,
        error: 'Action not approved',
        reason: approval.reason,
      };
    }
  },
});

// Usage
await chatkit.sendMessage({
  text: 'To delete your account, click below:',
  widgets: [
    {
      type: 'button',
      text: 'Delete Account',
      action: 'delete_account',
      style: 'danger',
    },
  ],
});
```

---

## Action Security

### Permission Checks

```typescript
chatkit.registerAction('access_sensitive_data', {
  // Check permissions before execution
  checkPermissions: async (params, context) => {
    const user = await getUser(context.userId);

    if (!user.permissions.includes('view_sensitive_data')) {
      throw new Error('Insufficient permissions');
    }

    // Additional checks
    if (user.role !== 'admin' && user.role !== 'manager') {
      throw new Error('Admin or manager role required');
    }

    return true;
  },

  execute: async (params, context) => {
    const data = await fetchSensitiveData(params.dataId);
    return { data };
  },
});
```

### Rate Limiting

```typescript
const actionRateLimits = new Map();

chatkit.registerAction('send_email', {
  validate: async (params, context) => {
    const userId = context.userId;
    const now = Date.now();

    // Check rate limit
    const userLimits = actionRateLimits.get(userId) || { count: 0, resetAt: now };

    if (now > userLimits.resetAt) {
      // Reset counter
      actionRateLimits.set(userId, { count: 1, resetAt: now + 3600000 });
    } else if (userLimits.count >= 10) {
      // Exceeded limit
      throw new Error('Rate limit exceeded. Try again in an hour.');
    } else {
      // Increment counter
      userLimits.count++;
      actionRateLimits.set(userId, userLimits);
    }

    return true;
  },

  execute: async (params) => {
    await sendEmail(params.to, params.subject, params.body);
    return { success: true };
  },
});
```

---

## Action Logging

### Audit Trail

```typescript
chatkit.registerAction('update_user_profile', {
  execute: async (params, context) => {
    // Log action start
    await logAction({
      action: 'update_user_profile',
      userId: context.userId,
      timestamp: new Date(),
      params: params,
      status: 'started',
    });

    try {
      // Execute action
      const result = await updateProfile(context.userId, params);

      // Log success
      await logAction({
        action: 'update_user_profile',
        userId: context.userId,
        timestamp: new Date(),
        params: params,
        status: 'completed',
        result: result,
      });

      return { success: true, result };
    } catch (error) {
      // Log error
      await logAction({
        action: 'update_user_profile',
        userId: context.userId,
        timestamp: new Date(),
        params: params,
        status: 'failed',
        error: error.message,
      });

      throw error;
    }
  },
});
```

---

## Action Notifications

### Real-time Updates

```typescript
chatkit.on('action:process_large_file', async (params) => {
  // Start processing
  const jobId = await startFileProcessing(params.fileId);

  // Send initial status
  const statusMessage = await chatkit.sendMessage({
    text: 'Processing file...',
    widget: {
      type: 'progress',
      percentage: 0,
    },
  });

  // Listen for progress updates
  fileProcessor.on('progress', async (progress) => {
    await chatkit.updateWidget(statusMessage.widgetId, {
      percentage: progress.percentage,
      message: progress.message,
    });
  });

  // Wait for completion
  const result = await fileProcessor.waitForCompletion(jobId);

  // Send completion message
  await chatkit.sendMessage({
    text: 'Processing complete!',
    widget: {
      type: 'card',
      title: 'File Processed',
      description: `${result.recordsProcessed} records processed`,
      actions: [
        { label: 'Download Results', action: 'download_results' },
      ],
    },
  });
});
```

---

## Error Handling

### Graceful Failures

```typescript
chatkit.registerAction('payment_action', {
  execute: async (params) => {
    try {
      const payment = await processPayment(params);
      return { success: true, paymentId: payment.id };
    } catch (error) {
      // Log error
      console.error('Payment failed:', error);

      // User-friendly error message
      await chatkit.sendMessage({
        text: 'Payment failed. Please try again or contact support.',
        widget: {
          type: 'card',
          title: 'Payment Error',
          description: getErrorMessage(error),
          actions: [
            { label: 'Retry', action: 'retry_payment' },
            { label: 'Contact Support', action: 'contact_support' },
          ],
        },
      });

      return { success: false, error: error.message };
    }
  },

  // Retry logic
  retry: {
    maxAttempts: 3,
    backoff: 'exponential',
    retryableErrors: ['network_error', 'timeout'],
  },
});
```

---

## Testing Actions

### Unit Testing

```typescript
import { describe, it, expect } from 'vitest';

describe('purchase_product action', () => {
  it('should validate parameters', async () => {
    const action = chatkit.getAction('purchase_product');

    await expect(
      action.validate({ quantity: -1 })
    ).rejects.toThrow('Valid quantity required');
  });

  it('should create order successfully', async () => {
    const action = chatkit.getAction('purchase_product');

    const result = await action.execute({
      productId: 'prod_123',
      quantity: 2,
      userId: 'user_456',
    });

    expect(result.success).toBe(true);
    expect(result.orderId).toBeDefined();
  });

  it('should handle out of stock', async () => {
    const action = chatkit.getAction('purchase_product');

    const result = await action.execute({
      productId: 'prod_out_of_stock',
      quantity: 1,
      userId: 'user_456',
    });

    expect(result.success).toBe(false);
    expect(result.error).toBe('Product out of stock');
  });
});
```

---

## Best Practices

### 1. Clear Action Names

```typescript
// ❌ Unclear
registerAction('do_thing', ...);

// ✅ Clear and descriptive
registerAction('create_customer_invoice', ...);
```

### 2. Validate Input

```typescript
registerAction('transfer_funds', {
  validate: (params) => {
    if (!params.amount || params.amount <= 0) {
      throw new Error('Valid amount required');
    }
    if (!params.fromAccount || !params.toAccount) {
      throw new Error('Both accounts required');
    }
    if (params.fromAccount === params.toAccount) {
      throw new Error('Cannot transfer to same account');
    }
    return true;
  },
  ...
});
```

### 3. Provide Feedback

```typescript
chatkit.on('action:submit_form', async (data) => {
  // Show processing state
  await chatkit.sendMessage('Processing...');

  // Execute action
  const result = await processForm(data);

  // Show result
  await chatkit.sendMessage(
    result.success
      ? '✅ Form submitted successfully!'
      : '❌ Submission failed. Please try again.'
  );
});
```

---

## Additional Resources

- **Actions API**: https://openai.github.io/chatkit-js/actions
- **Action Examples**: https://github.com/openai/openai-chatkit-advanced-samples
- **Security Best Practices**: https://platform.openai.com/docs/guides/safety

---

**Next**: [Advanced Integration →](./advanced-integration.md)
