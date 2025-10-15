# OpenAI Platform - Custom Theming

**Source:** https://platform.openai.com/docs/guides/chatkit/theming
**Fetched:** 2025-10-11

## Overview

Customize ChatKit's appearance to match your brand identity with themes, CSS variables, and custom components.

---

## Theme Configuration

### Basic Theme

```typescript
import { ChatKit } from '@openai/chatkit';

const theme = {
  mode: 'light',
  colors: {
    primary: '#10a37f',
    secondary: '#6e6e80',
    background: '#ffffff',
    surface: '#f7f7f8',
    text: '#202123',
  },
};

const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  theme: theme,
});
```

### Complete Theme Object

```typescript
const completeTheme = {
  // Mode
  mode: 'light' | 'dark' | 'auto',

  // Colors
  colors: {
    // Brand colors
    primary: '#10a37f',
    primaryHover: '#0e8c6f',
    primaryActive: '#0c7a5f',

    // Neutral colors
    background: '#ffffff',
    surface: '#f7f7f8',
    surfaceHover: '#ececf1',
    border: '#e5e5e5',
    divider: '#d9d9e3',

    // Text colors
    text: '#202123',
    textSecondary: '#6e6e80',
    textTertiary: '#acacbe',
    textInverse: '#ffffff',

    // Message colors
    userMessage: '#10a37f',
    userMessageText: '#ffffff',
    agentMessage: '#f7f7f8',
    agentMessageText: '#202123',

    // Status colors
    success: '#10a37f',
    error: '#ef4444',
    warning: '#f59e0b',
    info: '#3b82f6',

    // Interactive elements
    buttonPrimary: '#10a37f',
    buttonPrimaryHover: '#0e8c6f',
    buttonSecondary: '#ffffff',
    buttonSecondaryHover: '#f7f7f8',

    // Input colors
    inputBackground: '#ffffff',
    inputBorder: '#e5e5e5',
    inputFocus: '#10a37f',
    inputPlaceholder: '#acacbe',
  },

  // Typography
  fonts: {
    body: "'Inter', -apple-system, sans-serif",
    heading: "'Inter', -apple-system, sans-serif",
    mono: "'Roboto Mono', 'Courier New', monospace",
  },

  fontSizes: {
    xs: '12px',
    sm: '14px',
    base: '16px',
    lg: '18px',
    xl: '20px',
    '2xl': '24px',
  },

  fontWeights: {
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },

  // Spacing
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
    '2xl': '48px',
  },

  // Border radius
  borderRadius: {
    none: '0px',
    sm: '4px',
    base: '8px',
    lg: '12px',
    xl: '16px',
    full: '9999px',
  },

  // Shadows
  shadows: {
    sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    base: '0 1px 3px 0 rgb(0 0 0 / 0.1)',
    md: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
    lg: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
    xl: '0 20px 25px -5px rgb(0 0 0 / 0.1)',
  },

  // Transitions
  transitions: {
    fast: '150ms cubic-bezier(0.4, 0, 0.2, 1)',
    base: '200ms cubic-bezier(0.4, 0, 0.2, 1)',
    slow: '300ms cubic-bezier(0.4, 0, 0.2, 1)',
  },

  // Z-index
  zIndex: {
    base: 1,
    dropdown: 1000,
    modal: 1050,
    toast: 1100,
    tooltip: 1200,
  },
};
```

---

## Dark Mode

### Auto Dark Mode

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  theme: {
    mode: 'auto',  // Follows system preference
  },
});
```

### Manual Dark Mode

```typescript
const darkTheme = {
  mode: 'dark',
  colors: {
    primary: '#10a37f',
    background: '#202123',
    surface: '#2d2d30',
    text: '#ececf1',
    textSecondary: '#acacbe',
    border: '#444654',
    userMessage: '#10a37f',
    agentMessage: '#2d2d30',
  },
};

const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  theme: darkTheme,
});
```

### Toggle Dark Mode

```typescript
// Toggle at runtime
chatkit.setTheme({
  mode: chatkit.theme.mode === 'light' ? 'dark' : 'light',
});

// Or full theme switch
const lightTheme = {...};
const darkTheme = {...};

const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
chatkit.setTheme(isDark ? darkTheme : lightTheme);
```

---

## CSS Variables

### Using CSS Variables

```css
:root {
  /* Brand colors */
  --chatkit-primary: #10a37f;
  --chatkit-primary-hover: #0e8c6f;

  /* Background */
  --chatkit-bg: #ffffff;
  --chatkit-surface: #f7f7f8;

  /* Text */
  --chatkit-text: #202123;
  --chatkit-text-secondary: #6e6e80;

  /* Borders */
  --chatkit-border: #e5e5e5;
  --chatkit-border-radius: 8px;

  /* Spacing */
  --chatkit-spacing-sm: 8px;
  --chatkit-spacing-md: 16px;
  --chatkit-spacing-lg: 24px;

  /* Fonts */
  --chatkit-font-family: 'Inter', sans-serif;
  --chatkit-font-size: 16px;

  /* Shadows */
  --chatkit-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
}

/* Dark mode overrides */
[data-chatkit-theme="dark"] {
  --chatkit-bg: #202123;
  --chatkit-surface: #2d2d30;
  --chatkit-text: #ececf1;
  --chatkit-border: #444654;
}
```

### Override Specific Variables

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  cssVariables: {
    '--chatkit-primary': '#ff6b6b',
    '--chatkit-border-radius': '16px',
    '--chatkit-font-family': '"Comic Sans MS", cursive',
  },
});
```

---

## Custom Components

### Message Bubbles

```css
/* User message bubbles */
.chatkit-message-user {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 18px;
  padding: 12px 16px;
  color: white;
  max-width: 70%;
  margin-left: auto;
}

/* Agent message bubbles */
.chatkit-message-agent {
  background: #f7f7f8;
  border-radius: 18px;
  padding: 12px 16px;
  border: 1px solid #e5e5e5;
  max-width: 70%;
  margin-right: auto;
}

/* Add avatar */
.chatkit-message-agent::before {
  content: '';
  display: inline-block;
  width: 32px;
  height: 32px;
  background-image: url('/agent-avatar.png');
  background-size: cover;
  border-radius: 50%;
  margin-right: 12px;
  vertical-align: middle;
}
```

### Input Field

```css
.chatkit-input-container {
  background: white;
  border: 2px solid #e5e5e5;
  border-radius: 24px;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
}

.chatkit-input-container:focus-within {
  border-color: #10a37f;
  box-shadow: 0 0 0 3px rgba(16, 163, 127, 0.1);
}

.chatkit-input {
  flex: 1;
  border: none;
  outline: none;
  font-size: 16px;
  background: transparent;
}

.chatkit-send-button {
  background: #10a37f;
  color: white;
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.chatkit-send-button:hover {
  background: #0e8c6f;
  transform: scale(1.05);
}
```

### Typing Indicator

```css
.chatkit-typing-indicator {
  display: flex;
  gap: 4px;
  padding: 12px 16px;
  background: #f7f7f8;
  border-radius: 18px;
  width: fit-content;
}

.chatkit-typing-dot {
  width: 8px;
  height: 8px;
  background: #6e6e80;
  border-radius: 50%;
  animation: typing 1.4s infinite;
}

.chatkit-typing-dot:nth-child(2) {
  animation-delay: 0.2s;
}

.chatkit-typing-dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.7;
  }
  30% {
    transform: translateY(-10px);
    opacity: 1;
  }
}
```

---

## Brand Integration

### Full Brand Theme

```typescript
const brandTheme = {
  mode: 'light',

  colors: {
    // Use brand colors
    primary: '#FF6B6B',  // Brand red
    secondary: '#4ECDC4',  // Brand teal
    background: '#FFE66D',  // Brand yellow
    surface: '#FFFFFF',
    text: '#1A1A1A',

    // Message colors match brand
    userMessage: '#FF6B6B',
    userMessageText: '#FFFFFF',
    agentMessage: '#4ECDC4',
    agentMessageText: '#FFFFFF',

    // Buttons use brand colors
    buttonPrimary: '#FF6B6B',
    buttonPrimaryHover: '#FF5252',
  },

  fonts: {
    body: "'Poppins', sans-serif",  // Brand font
    heading: "'Montserrat', sans-serif",
  },

  borderRadius: {
    base: '20px',  // Rounded brand style
  },
};

const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  theme: brandTheme,
});
```

### Logo & Branding

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  branding: {
    logo: '/logo.svg',
    logoAlt: 'Company Name',
    logoWidth: 32,
    logoHeight: 32,
    showPoweredBy: false,  // Hide "Powered by OpenAI"
  },
});
```

---

## Responsive Design

### Mobile Optimization

```css
/* Desktop */
.chatkit-container {
  max-width: 400px;
  height: 600px;
  border-radius: 16px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

/* Tablet */
@media (max-width: 768px) {
  .chatkit-container {
    max-width: 100%;
    height: 500px;
    border-radius: 12px;
  }
}

/* Mobile */
@media (max-width: 640px) {
  .chatkit-container {
    max-width: 100%;
    height: 100vh;
    border-radius: 0;
  }

  .chatkit-message {
    max-width: 85%;
  }

  .chatkit-input {
    font-size: 16px;  /* Prevent zoom on iOS */
  }
}
```

---

## Advanced Styling

### Custom Animations

```css
/* Fade in messages */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.chatkit-message {
  animation: fadeIn 0.3s ease-out;
}

/* Slide in from side */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.chatkit-message-agent {
  animation: slideIn 0.3s ease-out;
}

.chatkit-message-user {
  animation: slideIn 0.3s ease-out reverse;
}
```

### Glassmorphism

```css
.chatkit-container {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
}

.chatkit-message {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(5px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}
```

### Neumorphism

```css
.chatkit-container {
  background: #e0e5ec;
  box-shadow:
    9px 9px 16px rgba(163, 177, 198, 0.6),
    -9px -9px 16px rgba(255, 255, 255, 0.5);
  border-radius: 20px;
}

.chatkit-message-user {
  background: #e0e5ec;
  box-shadow:
    inset 5px 5px 10px rgba(163, 177, 198, 0.6),
    inset -5px -5px 10px rgba(255, 255, 255, 0.5);
}
```

---

## Theme Presets

### Minimal Theme

```typescript
const minimalTheme = {
  mode: 'light',
  colors: {
    primary: '#000000',
    background: '#FFFFFF',
    surface: '#FAFAFA',
    text: '#000000',
    border: '#E0E0E0',
    userMessage: '#000000',
    agentMessage: '#F5F5F5',
  },
  borderRadius: { base: '4px' },
  fonts: {
    body: "'Helvetica Neue', Arial, sans-serif",
  },
};
```

### Vibrant Theme

```typescript
const vibrantTheme = {
  mode: 'light',
  colors: {
    primary: '#FF3366',
    secondary: '#33CCFF',
    background: '#FFFFFF',
    surface: '#FFF0F5',
    text: '#1A1A1A',
    userMessage: 'linear-gradient(135deg, #FF3366, #FF6B9D)',
    agentMessage: 'linear-gradient(135deg, #33CCFF, #66D9FF)',
  },
  borderRadius: { base: '24px' },
};
```

### Professional Theme

```typescript
const professionalTheme = {
  mode: 'light',
  colors: {
    primary: '#0066CC',
    background: '#FFFFFF',
    surface: '#F8F9FA',
    text: '#212529',
    border: '#DEE2E6',
    userMessage: '#0066CC',
    agentMessage: '#F8F9FA',
  },
  fonts: {
    body: "'Segoe UI', Tahoma, sans-serif",
  },
  borderRadius: { base: '8px' },
};
```

---

## Additional Resources

- **Theme Examples**: https://openai.github.io/chatkit-js/themes
- **CSS Reference**: https://openai.github.io/chatkit-js/css
- **Brand Guidelines**: https://openai.com/brand

---

**Next**: [Widgets →](./widgets.md)
