# UI Design Library - Quick Reference

> Design intelligence patterns and recommendations.

## Quick Lookup Tables

### Industry → Pattern Mapping

| Industry | Landing Page Pattern | Key Sections |
|----------|---------------------|--------------|
| SaaS | Hero-Centric + Feature Showcase | Hero, Features, Pricing, CTA |
| Fintech | Trust & Authority | Hero, Trust Badges, Features, Security |
| Healthcare | Social Proof + Trust | Hero, Services, Testimonials, Contact |
| E-commerce | Conversion-Optimized | Hero, Products, Reviews, Cart |
| Wellness/Spa | Hero-Centric + Social Proof | Hero, Services, Testimonials, Booking |
| Portfolio | Minimal & Direct | Hero, Work Gallery, About, Contact |
| Restaurant | Hero-Centric | Hero, Menu, Gallery, Reservations |
| Gaming | Feature-Rich Showcase | Hero, Features, Community, Download |

### Industry → Color Mood

| Industry | Primary Mood | Recommended Colors |
|----------|-------------|--------------------|
| Finance/Banking | Professional Trust | Navy Blue (#003366), Gold (#D4AF37), White |
| Healthcare | Calming Clean | Soft Blue (#4A90E2), Green (#7ED321), White |
| Wellness/Spa | Organic Premium | Soft Pink (#E8B4B8), Sage (#A8D5BA), Gold |
| E-commerce | Engaging Conversion | Orange (#FF6B35), Red (#E74C3C), Blue |
| SaaS/B2B | Modern Professional | Blue (#3498DB), Gray (#2C3E50), White |
| Gaming | Vibrant Immersive | Purple (#9B59B6), Neon (#00FF88), Black |
| Creative/Agency | Bold Expressive | Black (#1A1A2E), Vibrant accents |
| Legal/Consulting | Authority Trust | Navy (#003366), Gray (#6C757D), White |

### Industry → Typography Mood

| Industry | Typography Mood | Font Recommendations |
|----------|----------------|----------------------|
| Luxury/Premium | Elegant | Cormorant Garamond + Montserrat |
| Tech/SaaS | Modern | Inter + Roboto or Outfit + Plus Jakarta Sans |
| Healthcare | Clean | Open Sans + Lato |
| Gaming | Tech/Bold | Space Grotesk + JetBrains Mono |
| Finance | Professional | Helvetica Neue + Roboto |
| Creative | Expressive | Playfair Display + DM Sans |
| Enterprise | Minimal | Inter + system fonts |
| Education | Friendly | Nunito + Source Sans Pro |

### UI Style Selection Guide

| Style | Best Industries | Key Characteristics |
|-------|-----------------|---------------------|
| Minimalism | Enterprise, Docs, SaaS | Clean, functional, Swiss grid |
| Glassmorphism | Modern SaaS, Finance | Frosted glass, layered cards |
| Neumorphism | Wellness, Meditation | Soft shadows, tactile feel |
| Brutalism | Creative, Art, Portfolio | Bold, raw, high contrast |
| Dark Mode | Gaming, Dev tools, Crypto | OLED-optimized, eye comfort |
| Soft UI Evolution | Wellness, Premium services | Gentle shadows, calming |
| Bento Box Grid | Dashboards, Product pages | Card-based, modular |
| AI-Native UI | AI products, Chatbots | Dynamic, adaptive, conversational |
| Aurora UI | SaaS, Creative | Gradient backgrounds, glow effects |

## Pre-Delivery Checklist (Universal)

All UI implementations should validate:

### Accessibility
- [ ] Color contrast: Normal text ≥ 4.5:1, Large text ≥ 3:1
- [ ] All images have alt text
- [ ] All form inputs have labels
- [ ] Focus states visible (outline or custom)
- [ ] Keyboard navigation works
- [ ] Screen reader compatible

### Responsiveness
- [ ] Mobile (375px): All content accessible
- [ ] Tablet (768px): Layout adapts appropriately
- [ ] Desktop (1024px): Optimal viewing
- [ ] Large (1440px+): Content not stretched

### Performance
- [ ] Images optimized (lazy load, srcset)
- [ ] No layout shift during load
- [ ] Animations respect prefers-reduced-motion
- [ ] Fonts loaded efficiently (preconnect)

### Interaction
- [ ] cursor: pointer on clickable elements
- [ ] Hover states defined (150-300ms transitions)
- [ ] Loading states for async operations
- [ ] Error states with clear messages

### Anti-Patterns to Avoid

| Anti-Pattern | Why Avoid |
|--------------|-----------|
| Emojis as icons | Inconsistent, unprofessional |
| Generic AI gradients | Purple/pink = "AI-generated" look |
| Harsh animations | Jarring, accessibility issue |
| Dark mode without toggle | User preference ignored |
| Text over busy images | Legibility issues |
| Autoplay media | User control removed |
| Infinite scroll | Navigation, accessibility issues |

## Color Contrast Quick Reference

WCAG 2.1 Requirements:

| Text Size | Minimum Ratio | Level |
|-----------|---------------|-------|
| Normal (< 18px) | 4.5:1 | AA |
| Large (≥ 18px bold or ≥ 24px) | 3:1 | AA |
| Normal | 7:1 | AAA |
| Large | 4.5:1 | AAA |
| UI Components | 3:1 | AA |

Quick contrast check:
- Black (#000) on white (#FFF): 21:1 ✓✓✓
- Navy (#003366) on white: 12.6:1 ✓✓
- Gray (#6C757D) on white: 4.5:1 ✓
- Light gray (#ADB5BD) on white: 2.2:1 ✗

## Animation Timing Guide

| Animation Type | Duration | Easing |
|---------------|----------|--------|
| Hover states | 150-300ms | ease-out |
| Modal open/close | 200-400ms | ease-in-out |
| Page transitions | 300-500ms | ease |
| Loading spinners | 1-2s | linear (loop) |
| Attention-grabbing | 500-1000ms | bounce/ease-out |

## Font Loading Best Practices

```html
<!-- Preconnect to Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<!-- Load fonts with display: swap -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
```

Or in CSS:
```css
font-display: swap; /* Show fallback immediately, swap when loaded */
```