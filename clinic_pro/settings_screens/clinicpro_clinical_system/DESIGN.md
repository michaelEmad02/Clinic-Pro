---
name: ClinicPro Clinical System
colors:
  surface: '#FFFFFF'
  surface-dim: '#d8dadd'
  surface-bright: '#f7f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f7'
  surface-container: '#eceef1'
  surface-container-high: '#e6e8eb'
  surface-container-highest: '#e0e3e6'
  on-surface: '#191c1e'
  on-surface-variant: '#40484d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f4'
  outline: '#70787e'
  outline-variant: '#bfc8ce'
  surface-tint: '#106685'
  primary: '#00526d'
  on-primary: '#ffffff'
  primary-container: '#1a6b8a'
  on-primary-container: '#bce7ff'
  inverse-primary: '#8bcff2'
  secondary: '#006c4e'
  on-secondary: '#ffffff'
  secondary-container: '#67f8c3'
  on-secondary-container: '#007152'
  tertiary: '#6a4300'
  on-tertiary: '#ffffff'
  tertiary-container: '#8a5900'
  on-tertiary-container: '#ffdbaf'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c0e8ff'
  primary-fixed-dim: '#8bcff2'
  on-primary-fixed: '#001e2b'
  on-primary-fixed-variant: '#004d66'
  secondary-fixed: '#6afbc6'
  secondary-fixed-dim: '#48deab'
  on-secondary-fixed: '#002115'
  on-secondary-fixed-variant: '#00513a'
  tertiary-fixed: '#ffddb4'
  tertiary-fixed-dim: '#ffb955'
  on-tertiary-fixed: '#291800'
  on-tertiary-fixed-variant: '#633f00'
  background: '#f7f9fc'
  on-background: '#191c1e'
  surface-variant: '#e0e3e6'
  danger: '#E84C4C'
  border: '#E2E8F0'
  text-primary: '#1A202C'
  text-secondary: '#64748B'
  text-hint: '#A0AEC0'
  primary-light: '#EAF4F8'
  success-bg: '#D1FAE5'
  success-text: '#065F46'
  warning-bg: '#FEF3C7'
  warning-text: '#92400E'
  danger-bg: '#FEE2E2'
  danger-text: '#991B1B'
typography:
  headline-lg:
    fontFamily: Cairo
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Cairo
    fontSize: 22px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-sm:
    fontFamily: Cairo
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Cairo
    fontSize: 15px
    fontWeight: '400'
    lineHeight: '1.5'
  body-md:
    fontFamily: Cairo
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  caption:
    fontFamily: Cairo
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '1.4'
  label-chip:
    fontFamily: Cairo
    fontSize: 11px
    fontWeight: '500'
    lineHeight: '1'
  data-numeric:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '700'
    lineHeight: '1'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  screen-edge-h: 16px
  screen-edge-v: 20px
  list-item-height: 72px
---

## Brand & Style

This design system is engineered for the high-stakes environment of healthcare management, where clarity, trust, and speed of information processing are paramount. The brand personality is **Professional, Reliable, and Clinical**, utilizing a sophisticated "Petrol Blue" primary palette that distinguishes the product as a premium SaaS solution rather than a generic medical utility.

The design style follows a **Corporate / Modern** approach with a heavy emphasis on **Information Density and Structural Hierarchy**. It is specifically optimized for RTL (Arabic) environments, ensuring that the visual flow and ergonomics—such as the bottom-left placement of action buttons—feel natural to the target user base. The system balances high-density data (using Inter for numerical precision) with a clean, airy interface (using Cairo for linguistic warmth) to reduce cognitive load during long shifts.

## Colors

The color palette is functionally segmented to provide immediate semantic meaning. 

- **Primary (#1A6B8A)** serves as the anchor for brand identity and high-priority actions.
- **Accent/Success (#2ECC9A)** is reserved for positive confirmations and "online" status indicators.
- **Warning (#F5A623)** and **Danger (#E84C4C)** are used strictly for alerts, pending states, and critical errors or cancellations.

Backgrounds utilize a cool-toned neutral (#F7F9FC) to allow the white Surface (#FFFFFF) containers to "pop" without harsh contrast. Status badges use a dual-tone "Pill" logic, pairing high-chroma text with low-saturation backgrounds of the same hue to ensure legibility and categorization at a glance.

## Typography

This system employs a dual-font strategy to optimize for a bilingual, data-heavy environment. 

**Cairo** is the primary typeface for all linguistic content, providing excellent legibility for Arabic script. **Inter** (Bold) is used exclusively for "Data" roles—all numbers, dates, amounts, and counts—to provide a distinct visual anchor for quantitative information that remains legible even at small sizes.

On mobile devices, ensure that `headline-lg` is used sparingly for splash and high-level detail screens. Maintain the 1.5 line-height for body text to ensure comfortable reading of medical reports and notes.

## Layout & Spacing

The layout is built on a strict **4px/8px incremental scale**. This mathematical rhythm ensures harmony across diverse screen sizes.

- **Grid Philosophy**: Use a **Fluid Grid** for mobile, transitioning to a **Fixed Master-Detail** layout for tablets (768px+). 
- **Mobile Layout**: Employs a single column with 16px horizontal margins.
- **Tablet/Desktop Layout**: Lists transition to dual columns or a sidebar-content split. Bottom sheets should be constrained to a 480px max-width and centered on larger screens.
- **RTL Considerations**: All padding and margins are mirrored. The FAB is positioned in the bottom-left to prioritize thumb-reach in RTL usage.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Subtle Ambient Shadows**. The system avoids heavy shadows to maintain a clean "clinical" look.

- **Surface Layers**: The background is the lowest tier (#F7F9FC), with Cards and Sheets (#FFFFFF) sitting above it.
- **Card Elevation**: Uses a very subtle, low-blur shadow (`0 1px 3px rgba(0,0,0,0.08)`) to suggest a slight lift without appearing detached.
- **Floating Action Button (FAB)**: Uses a thematic shadow tinted with the primary color (`0 4px 16px rgba(26,107,138,0.25)`) to emphasize the most important action.
- **Overlays (Bottom Sheets)**: Use a directional upward shadow (`0 -4px 24px rgba(0,0,0,0.12)`) to indicate they are emerging from the bottom of the screen.

## Shapes

The design system uses "Soft Geometric" shapes with specific radii assigned to components based on their role and size:

- **Bottom Sheets**: 24px on top corners only.
- **Chips**: 20px (full pill-shape) to distinguish them from buttons.
- **Cards**: 16px for a soft, approachable container feel.
- **Buttons**: 12px for a professional, sturdy appearance.
- **Inputs**: 10px for a slightly tighter, more technical look.

Standard dividers must be 0.5px for a refined, high-end finish that minimizes visual noise in dense lists.

## Components

### Buttons
- **Primary**: Solid #1A6B8A with 12px radius. 
- **Outlined**: 1px border (#E2E8F0) for secondary actions.
- **FAB**: 56x56px, Primary color, white icon, located bottom-left.

### Chips & Badges
- **Status Pills**: 20px radius. Use the semantic background/text pairs (e.g., Success-BG for "Confirmed").
- **Interactive Chips**: Primary Light background (#EAF4F8) with Primary text.

### Input Fields
- **Default**: 10px radius, 1px border (#E2E8F0).
- **Placeholder**: Use Text Hint (#A0AEC0).
- **Active**: 1px Primary color border.

### Cards
- **Structure**: 16px radius, subtle elevation.
- **Interactive**: For "Selected" or "Featured" cards, use a 1px Primary border.

### Bottom Navigation
- **Height**: 64px.
- **Active State**: Primary color with a filled icon.
- **Inactive State**: Text Secondary color with an outlined icon.

### Empty States
- Consists of a 64px Primary Light icon, followed by H3 title, body description, and a Primary Outlined action button.

### Realtime Indicators
- Use a Green (#2ECC9A) dot with a soft "Pulse" animation to indicate live waiting queues or active dashboard updates.