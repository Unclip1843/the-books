# OpenAI Platform - Widgets

**Source:** https://platform.openai.com/docs/guides/chatkit/widgets
**Fetched:** 2025-10-11

## Overview

Widgets are interactive components that can be embedded directly in ChatKit conversations, enabling rich user interactions beyond simple text messages.

---

## Built-in Widgets

### Button Widget

Interactive buttons for user actions.

```typescript
{
  type: 'button',
  text: 'Confirm Order',
  action: 'confirm_order',
  style: 'primary' | 'secondary' | 'danger',
  disabled: false,
  metadata: { orderId: '12345' }
}
```

**Example**:
```typescript
await chatkit.sendMessage({
  text: 'Would you like to proceed?',
  widgets: [
    {
      type: 'button',
      text: 'Yes, Confirm',
      action: 'confirm',
      style: 'primary',
    },
    {
      type: 'button',
      text: 'Cancel',
      action: 'cancel',
      style: 'secondary',
    },
  ],
});

// Handle button clicks
chatkit.on('widgetAction', (action, data) => {
  if (action === 'confirm') {
    processOrder(data.metadata.orderId);
  }
});
```

---

### Form Widget

Collect structured input from users.

```typescript
{
  type: 'form',
  title: 'Contact Information',
  fields: [
    {
      name: 'email',
      label: 'Email Address',
      type: 'email',
      required: true,
      placeholder: 'you@example.com',
    },
    {
      name: 'phone',
      label: 'Phone Number',
      type: 'tel',
      required: false,
      placeholder: '(555) 123-4567',
    },
    {
      name: 'message',
      label: 'Message',
      type: 'textarea',
      required: true,
      rows: 4,
    },
    {
      name: 'subscribe',
      label: 'Subscribe to newsletter',
      type: 'checkbox',
      required: false,
    },
  ],
  submitLabel: 'Submit',
  cancelLabel: 'Cancel',
}
```

**Field Types**:
- `text` - Single-line text input
- `email` - Email input with validation
- `tel` - Phone number input
- `number` - Numeric input
- `date` - Date picker
- `time` - Time picker
- `textarea` - Multi-line text
- `select` - Dropdown selection
- `checkbox` - Boolean checkbox
- `radio` - Radio button group

**Example**:
```typescript
await chatkit.sendMessage({
  text: 'Please fill out your information:',
  widget: {
    type: 'form',
    fields: [
      { name: 'name', type: 'text', required: true },
      { name: 'email', type: 'email', required: true },
    ],
    submitLabel: 'Continue',
  },
});

// Handle form submission
chatkit.on('formSubmit', (formData) => {
  console.log('Form submitted:', formData);
  // { name: 'John Doe', email: 'john@example.com' }
});
```

---

### Card Widget

Display rich content with images and actions.

```typescript
{
  type: 'card',
  title: 'Product Name',
  subtitle: 'Premium Edition',
  description: 'High-quality product with amazing features...',
  image: 'https://example.com/product.jpg',
  imageAlt: 'Product photo',
  price: '$99.99',
  actions: [
    {
      label: 'Buy Now',
      action: 'purchase',
      style: 'primary',
    },
    {
      label: 'Learn More',
      action: 'details',
      style: 'secondary',
    },
  ],
  metadata: { productId: 'prod_123' },
}
```

**Example**:
```typescript
await chatkit.sendMessage({
  text: 'Check out this product:',
  widget: {
    type: 'card',
    title: 'Wireless Headphones',
    description: 'Premium noise-cancelling headphones',
    image: '/headphones.jpg',
    price: '$299',
    actions: [
      { label: 'Add to Cart', action: 'add_cart' },
    ],
  },
});
```

---

### Carousel Widget

Multiple cards in a scrollable carousel.

```typescript
{
  type: 'carousel',
  items: [
    {
      title: 'Product 1',
      image: '/product1.jpg',
      description: 'Description...',
      actions: [{ label: 'View', action: 'view_1' }],
    },
    {
      title: 'Product 2',
      image: '/product2.jpg',
      description: 'Description...',
      actions: [{ label: 'View', action: 'view_2' }],
    },
    {
      title: 'Product 3',
      image: '/product3.jpg',
      description: 'Description...',
      actions: [{ label: 'View', action: 'view_3' }],
    },
  ],
}
```

---

### List Widget

Structured list of items.

```typescript
{
  type: 'list',
  title: 'Search Results',
  items: [
    {
      title: 'Item 1',
      subtitle: 'Details about item 1',
      icon: '📄',
      action: 'select_1',
    },
    {
      title: 'Item 2',
      subtitle: 'Details about item 2',
      icon: '📊',
      action: 'select_2',
    },
    {
      title: 'Item 3',
      subtitle: 'Details about item 3',
      icon: '📈',
      action: 'select_3',
    },
  ],
  selectable: true,
  multiSelect: false,
}
```

---

### Chart Widget

Data visualizations.

```typescript
{
  type: 'chart',
  chartType: 'line' | 'bar' | 'pie' | 'doughnut',
  title: 'Sales Over Time',
  data: {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
    datasets: [
      {
        label: 'Sales',
        data: [12, 19, 3, 5, 2],
        backgroundColor: 'rgba(16, 163, 127, 0.2)',
        borderColor: 'rgba(16, 163, 127, 1)',
        borderWidth: 2,
      },
    ],
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
  },
}
```

**Chart Types**:
- `line` - Line chart
- `bar` - Bar chart
- `pie` - Pie chart
- `doughnut` - Doughnut chart
- `radar` - Radar chart
- `scatter` - Scatter plot

**Example**:
```typescript
await chatkit.sendMessage({
  text: 'Here are your sales metrics:',
  widget: {
    type: 'chart',
    chartType: 'bar',
    data: {
      labels: ['Q1', 'Q2', 'Q3', 'Q4'],
      datasets: [{
        label: 'Revenue',
        data: [25000, 35000, 42000, 38000],
      }],
    },
  },
});
```

---

### Image Widget

Display images with captions.

```typescript
{
  type: 'image',
  url: 'https://example.com/image.jpg',
  alt: 'Image description',
  caption: 'Image caption',
  width: 400,
  height: 300,
  thumbnail: 'https://example.com/thumb.jpg',
}
```

---

### File Widget

File attachments with metadata.

```typescript
{
  type: 'file',
  name: 'document.pdf',
  size: 1024000,  // bytes
  url: 'https://example.com/document.pdf',
  mimeType: 'application/pdf',
  icon: '📄',
  actions: [
    { label: 'Download', action: 'download' },
    { label: 'Preview', action: 'preview' },
  ],
}
```

---

### Progress Widget

Show progress for long-running tasks.

```typescript
{
  type: 'progress',
  title: 'Processing...',
  percentage: 45,
  status: 'in_progress' | 'completed' | 'error',
  message: 'Analyzing documents...',
  showPercentage: true,
}
```

**Example**:
```typescript
// Start progress
const progressWidget = await chatkit.sendMessage({
  text: 'Starting analysis...',
  widget: {
    type: 'progress',
    percentage: 0,
    status: 'in_progress',
  },
});

// Update progress
await chatkit.updateWidget(progressWidget.id, {
  percentage: 50,
  message: 'Half way there...',
});

// Complete
await chatkit.updateWidget(progressWidget.id, {
  percentage: 100,
  status: 'completed',
  message: 'Analysis complete!',
});
```

---

### Calendar Widget

Date/time selection.

```typescript
{
  type: 'calendar',
  title: 'Select a date',
  mode: 'single' | 'multiple' | 'range',
  minDate: '2025-01-01',
  maxDate: '2025-12-31',
  selectedDates: ['2025-10-11'],
  disabledDates: ['2025-12-25'],
}
```

---

### Rating Widget

Collect user ratings.

```typescript
{
  type: 'rating',
  title: 'How would you rate your experience?',
  maxStars: 5,
  currentRating: 0,
  allowHalf: true,
  showLabels: true,
  labels: ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent'],
}
```

---

## Custom Widgets

### Creating Custom Widgets

```typescript
// Define custom widget
chatkit.registerWidget('product-comparison', {
  // Render function
  render: (data) => {
    return `
      <div class="product-comparison">
        <div class="product">
          <img src="${data.product1.image}" alt="${data.product1.name}">
          <h3>${data.product1.name}</h3>
          <p>$${data.product1.price}</p>
        </div>
        <div class="vs">VS</div>
        <div class="product">
          <img src="${data.product2.image}" alt="${data.product2.name}">
          <h3>${data.product2.name}</h3>
          <p>$${data.product2.price}</p>
        </div>
      </div>
    `;
  },

  // Event handlers
  handlers: {
    click: (event, data) => {
      console.log('Comparison clicked:', data);
    },
  },

  // Styles (optional)
  styles: `
    .product-comparison {
      display: flex;
      gap: 20px;
      align-items: center;
    }
    .product {
      flex: 1;
      text-align: center;
    }
    .vs {
      font-weight: bold;
      font-size: 24px;
    }
  `,
});

// Use custom widget
await chatkit.sendMessage({
  text: 'Compare these products:',
  widget: {
    type: 'product-comparison',
    data: {
      product1: {
        name: 'Product A',
        image: '/a.jpg',
        price: 99,
      },
      product2: {
        name: 'Product B',
        image: '/b.jpg',
        price: 149,
      },
    },
  },
});
```

---

## Widget Actions

### Handling Widget Actions

```typescript
// Listen for widget actions
chatkit.on('widgetAction', (action, data, widgetId) => {
  console.log(`Action: ${action}`);
  console.log('Data:', data);
  console.log('Widget ID:', widgetId);

  switch (action) {
    case 'confirm':
      handleConfirm(data);
      break;
    case 'cancel':
      handleCancel(data);
      break;
    case 'purchase':
      handlePurchase(data.metadata.productId);
      break;
  }
});
```

### Updating Widgets

```typescript
// Send widget
const message = await chatkit.sendMessage({
  text: 'Processing...',
  widget: {
    type: 'progress',
    percentage: 0,
  },
});

// Update widget
await chatkit.updateWidget(message.widgetId, {
  percentage: 50,
  message: 'Almost done...',
});

// Remove widget
await chatkit.removeWidget(message.widgetId);
```

---

## Widget Styling

### Custom Widget Styles

```css
/* Style button widgets */
.chatkit-widget-button {
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.2s;
}

.chatkit-widget-button-primary {
  background: #10a37f;
  color: white;
}

.chatkit-widget-button-primary:hover {
  background: #0e8c6f;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 163, 127, 0.3);
}

/* Style card widgets */
.chatkit-widget-card {
  border: 1px solid #e5e5e5;
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s;
}

.chatkit-widget-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  transform: translateY(-4px);
}

.chatkit-widget-card-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}
```

---

## Best Practices

### 1. Keep Widgets Simple

```typescript
// ❌ Too complex
{
  type: 'card',
  title: 'Product with 20 fields...',
  // 50 lines of configuration
}

// ✅ Simple and focused
{
  type: 'card',
  title: 'Product Name',
  description: 'Brief description',
  actions: [{ label: 'View', action: 'view' }],
}
```

### 2. Provide Clear Actions

```typescript
// ❌ Unclear
{ label: 'OK', action: 'action1' }

// ✅ Clear and descriptive
{ label: 'Confirm Purchase', action: 'confirm_purchase' }
```

### 3. Handle Loading States

```typescript
// Show loading widget
await chatkit.sendMessage({
  text: 'Loading products...',
  widget: {
    type: 'progress',
    percentage: 0,
    status: 'in_progress',
  },
});

// Update with results
await chatkit.sendMessage({
  text: 'Here are your products:',
  widget: {
    type: 'carousel',
    items: products,
  },
});
```

### 4. Validate User Input

```typescript
chatkit.on('formSubmit', (formData) => {
  // Validate
  if (!formData.email.includes('@')) {
    chatkit.showError('Please enter a valid email');
    return;
  }

  // Process
  processForm(formData);
});
```

---

## Examples

### E-commerce Product Selector

```typescript
await chatkit.sendMessage({
  text: 'Select a product:',
  widget: {
    type: 'carousel',
    items: [
      {
        title: 'Laptop',
        image: '/laptop.jpg',
        description: 'High-performance laptop',
        price: '$1299',
        actions: [
          { label: 'Add to Cart', action: 'add_cart_laptop' },
          { label: 'Details', action: 'details_laptop' },
        ],
      },
      {
        title: 'Phone',
        image: '/phone.jpg',
        description: 'Latest smartphone',
        price: '$899',
        actions: [
          { label: 'Add to Cart', action: 'add_cart_phone' },
          { label: 'Details', action: 'details_phone' },
        ],
      },
    ],
  },
});
```

### Feedback Form

```typescript
await chatkit.sendMessage({
  text: 'How was your experience?',
  widget: {
    type: 'form',
    fields: [
      {
        name: 'rating',
        type: 'radio',
        label: 'Overall Rating',
        options: [
          { value: '5', label: '⭐⭐⭐⭐⭐' },
          { value: '4', label: '⭐⭐⭐⭐' },
          { value: '3', label: '⭐⭐⭐' },
          { value: '2', label: '⭐⭐' },
          { value: '1', label: '⭐' },
        ],
        required: true,
      },
      {
        name: 'comments',
        type: 'textarea',
        label: 'Additional Comments',
        placeholder: 'Tell us more...',
      },
    ],
    submitLabel: 'Submit Feedback',
  },
});
```

### Appointment Scheduler

```typescript
await chatkit.sendMessage({
  text: 'Schedule an appointment:',
  widget: {
    type: 'calendar',
    mode: 'single',
    minDate: new Date().toISOString().split('T')[0],
    disabledDates: ['2025-12-25', '2025-01-01'],  // Holidays
  },
});

chatkit.on('dateSelected', async (date) => {
  await chatkit.sendMessage({
    text: 'Select a time:',
    widget: {
      type: 'list',
      items: [
        { title: '9:00 AM', action: 'schedule_9am' },
        { title: '11:00 AM', action: 'schedule_11am' },
        { title: '2:00 PM', action: 'schedule_2pm' },
        { title: '4:00 PM', action: 'schedule_4pm' },
      ],
    },
  });
});
```

---

## Additional Resources

- **Widget Showcase**: https://openai.github.io/chatkit-js/widgets
- **Custom Widgets Guide**: https://openai.github.io/chatkit-js/custom-widgets
- **Widget Examples**: https://github.com/openai/openai-chatkit-advanced-samples

---

**Next**: [Actions →](./actions.md)
