# Modern UI Design - Quick Reference Guide

## 📊 Design System Overview

### Color Palette (Modern 2.0)

```
Primary:          #0066FF  (Blue)      - Main CTAs, primary buttons
Primary Dark:     #0052CC  (Navy Blue) - Darker elements, gradients
Primary Light:    #3385FF  (Light Blue)- Secondary highlights
Primary Soft:     #C2E0FF  (Light)     - Background tints
Primary Surface:  #E6F2FF  (Very Light)- Card backgrounds

Accent:           #FF6B35  (Orange)   - Secondary CTAs, highlights
Accent Light:     #FF8C61  (Light Orange) - Hover states

Purple:           #9D4EDD  (Purple)   - Tertiary actions, AI related
Purple Light:     #C77DFF  (Light Purple) - Light backgrounds

Success:          #10B981  (Green)    - Positive feedback
Warning:          #FF9800  (Orange)   - Warnings, alerts
Error:            #EF4444  (Red)      - Errors, destructive

Text Primary:     #0F0F1E  (Dark)     - Main text
Text Secondary:   #5A5A6F  (Gray)     - Secondary text
Text Hint:        #8A8A9E  (Light Gray)- Disabled, hints
Background:       #FAFBFF  (White)    - Page background
Surface:          #FFFFFF  (White)    - Card backgrounds
Divider:          #E8EAF6  (Light)    - Borders, dividers
```

---

## 🎨 Component Styling

### Buttons

**Primary Button** (Gradient)
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primary.withValues(alpha: 0.25),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
)
```

**Secondary Button** (Surface)
```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surface,
    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    border: Border.all(color: AppTheme.divider),
    boxShadow: AppTheme.softShadow,
  ),
)
```

### Cards

**Standard Card**
```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surface,
    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    boxShadow: AppTheme.softShadow,
    border: Border.all(color: AppTheme.divider, width: 1),
  ),
)
```

**Hero Card**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
    boxShadow: AppTheme.mediumShadow,
    overflow: Overflow.clip,
  ),
)
```

### Icon Containers

**Color-Coded Icon Box**
```dart
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
  ),
  child: Center(child: Icon(icon, color: color, size: 22)),
)
```

### Badges

**Modern Badge**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  decoration: BoxDecoration(
    color: AppTheme.accent,
    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
    boxShadow: [
      BoxShadow(
        color: AppTheme.accent.withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
)
```

---

## 📐 Spacing & Sizing

### Standard Spacing Scale
```
XS: 4px
SM: 8px
MD: 16px
LG: 24px
XL: 32px
XXL: 48px
```

### Border Radius
```
Small:    8px   (small icons, minimal corners)
Medium:   12px  (icon containers)
Large:    16px  (buttons, standard cards)
XLarge:   24px  (section containers)
XXLarge:  32px  (hero sections)
Round:    50px  (badges, pills)
```

### Component Sizing
```
Icon (small):     22px
Icon (medium):    24px
Icon (large):     26px
Avatar:           44-52px
Button height:    48-52px
Search bar:       52px
Navigation item:  40-56px
```

---

## 🖋️ Typography

### Font Sizes & Weights

**Heading Large**
```
Size: 32px
Weight: 900
Letter Spacing: -0.8px
Height: 1.1
Usage: Main page titles
```

**Heading Medium**
```
Size: 24px
Weight: 800
Letter Spacing: -0.5px
Height: 1.2
Usage: Section titles, card titles
```

**Heading Small**
```
Size: 18px
Weight: 700
Letter Spacing: -0.2px
Usage: Subsection titles
```

**Body Large**
```
Size: 16px
Weight: 500
Height: 1.6
Usage: Body text, descriptions
```

**Body Medium**
```
Size: 14px
Weight: 400
Height: 1.5
Usage: Secondary text
```

**Body Small**
```
Size: 12px
Weight: 400
Height: 1.4
Usage: Hints, helper text
```

**Label Bold**
```
Size: 14px
Weight: 700
Letter Spacing: 0.2px
Usage: Labels, tags
```

**Caption**
```
Size: 11px
Weight: 600
Letter Spacing: 0.5px
Usage: Captions, timestamps
```

---

## ✨ Shadow System

### Soft Shadow
```dart
AppTheme.softShadow = [
  BoxShadow(
    color: cardShadow.withValues(alpha: 0.08),
    blurRadius: 24,
    offset: Offset(0, 4),
  ),
]
```
*Use for: Standard cards, buttons, normal elevation*

### Medium Shadow
```dart
AppTheme.mediumShadow = [
  BoxShadow(
    color: cardShadow.withValues(alpha: 0.12),
    blurRadius: 32,
    offset: Offset(0, 8),
  ),
]
```
*Use for: Hero cards, elevated sections*

### Large Shadow
```dart
AppTheme.largeShadow = [
  BoxShadow(
    color: cardShadow.withValues(alpha: 0.15),
    blurRadius: 40,
    offset: Offset(0, 12),
  ),
]
```
*Use for: Modals, floating elements*

---

## 🎯 Gradients

### Primary Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0052CC), Color(0xFF0066FF)],
)
```

### Accent Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
)
```

### Purple Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF9D4EDD), Color(0xFFC77DFF)],
)
```

### Hero Overlay Gradient
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.transparent,
    Colors.black.withValues(alpha: 0.4),
    Colors.black.withValues(alpha: 0.7),
  ],
)
```

---

## 🔧 Common Patterns

### Modern Quick Action Card
```dart
GestureDetector(
  onTap: onTap,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
    decoration: BoxDecoration(
      gradient: highlighted ? AppTheme.primaryGradient : null,
      color: highlighted ? null : AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      boxShadow: highlighted ? 
        [BoxShadow(...)] : AppTheme.softShadow,
      border: !highlighted ? 
        Border.all(color: AppTheme.divider) : null,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: highlighted ? Colors.white.withValues(alpha: 0.2) 
              : AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Center(child: Icon(...)),
        ),
        SizedBox(height: 10),
        Text(label, style: AppTheme.caption),
      ],
    ),
  ),
)
```

### Modern Header Section
```dart
Padding(
  padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: AppTheme.bodyMedium),
          SizedBox(height: 4),
          Text(title, style: AppTheme.headingLarge),
        ],
      ),
      Row(
        children: [
          // Notification icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.softShadow,
            ),
            child: Icon(...),
          ),
          SizedBox(width: 12),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Center(child: Text(initials)),
          ),
        ],
      ),
    ],
  ),
)
```

---

## ✅ Checklist for New Components

- [ ] Use `AppTheme.radiusLarge` (16px) as default border radius
- [ ] Apply `AppTheme.softShadow` for standard elevation
- [ ] Set `color: AppTheme.surface` with `divider` border for secondary elements
- [ ] Use gradient only for primary CTAs
- [ ] Maintain consistent spacing (multiples of 4px)
- [ ] Use color-coded icon containers instead of plain icons
- [ ] Apply modern shadows (not hard shadows)
- [ ] Use `AppTheme` colors (never hardcoded colors)
- [ ] Test on multiple screen sizes
- [ ] Ensure text contrast meets accessibility standards

---

## 🚀 Best Practices

1. **Consistency**: Always use `AppTheme` constants, never hardcode values
2. **Hierarchy**: Use typography scale (Large > Medium > Small) consistently
3. **Color**: Use accent colors sparingly for CTAs and highlights
4. **Spacing**: Use multiples of 4px from spacing scale
5. **Shadows**: Use appropriate shadow levels (soft < medium < large)
6. **Icons**: Place in 40-44px containers with light backgrounds
7. **Gradients**: Reserve for primary actions and hero sections
8. **Borders**: Use divider color with 1px weight
9. **Interactive**: Provide visual feedback (color change, shadows)
10. **Accessibility**: Ensure sufficient color contrast (WCAG AA minimum)

---

## 📱 Responsive Design

### Padding Adjustments
- **Phone (< 400px)**: Reduce padding by 4px
- **Standard (400-600px)**: Use standard padding (24px)
- **Tablet (> 600px)**: Increase padding by 4-8px

### Typography Adjustments
- **Phone**: Reduce font size by 1-2px for body text
- **Standard**: Use theme defaults
- **Tablet**: Increase by 1-2px for readability

---

## 🎨 Example Screen Layout

```dart
Scaffold(
  backgroundColor: AppTheme.background,
  body: SafeArea(
    child: CustomScrollView(
      slivers: [
        // Header with modern styling
        SliverToBoxAdapter(child: _buildHeader()),
        
        // Search bar with gradient filter
        SliverToBoxAdapter(child: _buildSearchBar()),
        
        // Hero card with badge
        SliverToBoxAdapter(child: _buildHeroCard()),
        
        // Quick actions grid
        SliverToBoxAdapter(child: _buildQuickActions()),
        
        // Content sections
        SliverToBoxAdapter(child: _buildSection1()),
        SliverToBoxAdapter(child: _buildSection2()),
        
        SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    ),
  ),
)
```

---

*Last Updated: 2026-04-28*
*Design System Version: 2.0 (Modern)*
