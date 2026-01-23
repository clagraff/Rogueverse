/// Centralized UI constants for consistent styling across the app.
///
/// Import this file to use standardized spacing, dimensions, and styling values
/// rather than hardcoded magic numbers.
library;

import 'package:flutter/material.dart';

// =============================================================================
// SPACING - Standard spacing values for padding and margins
// =============================================================================

/// Extra small spacing (2px) - minimal gaps
const double kSpacingXS = 2;

/// Small spacing (4px) - tight gaps between related elements
const double kSpacingS = 4;

/// Medium spacing (8px) - standard gap between elements
const double kSpacingM = 8;

/// Large spacing (12px) - comfortable spacing
const double kSpacingL = 12;

/// Extra large spacing (16px) - section separation
const double kSpacingXL = 16;

/// Double extra large spacing (24px) - major section separation
const double kSpacingXXL = 24;

/// Maximum spacing (32px) - screen-level padding
const double kSpacingMax = 32;

// =============================================================================
// BORDER RADIUS - Standard corner rounding values
// =============================================================================

/// Small border radius (4px) - subtle rounding for buttons, chips
const double kRadiusS = 4;

/// Medium border radius (6px) - tabs, small cards
const double kRadiusM = 6;

/// Large border radius (8px) - cards, panels
const double kRadiusL = 8;

/// Extra large border radius (12px) - dialogs, major containers
const double kRadiusXL = 12;

// =============================================================================
// ELEVATION - Material Design shadow depths
// =============================================================================

/// Low elevation (4) - subtle depth for panels
const double kElevationLow = 4;

/// Medium elevation (8) - context menus, dropdowns
const double kElevationMedium = 8;

/// High elevation (16) - dialogs, modal overlays
const double kElevationHigh = 16;

// =============================================================================
// OVERLAY DIMENSIONS - Standard sizes for dialogs and overlays
// =============================================================================

/// Standard dialog max width
const double kDialogMaxWidth = 600;

/// Standard dialog max height
const double kDialogMaxHeight = 400;

/// Character screen overlay max width
const double kCharacterScreenMaxWidth = 700;

/// Character screen overlay max height
const double kCharacterScreenMaxHeight = 500;

/// Panel content max height (for scrollable sections)
const double kPanelMaxHeight = 200;

/// Component dialog dimensions
const double kComponentDialogWidth = 300;
const double kComponentDialogHeight = 400;

// =============================================================================
// PANEL DIMENSIONS - Standard widths for side panels
// =============================================================================

/// Tree view panel width (e.g., dialog editor left panel)
const double kTreeViewPanelWidth = 350;

/// Vision observer panel width
const double kVisionPanelWidth = 280;

/// Menu button width
const double kMenuButtonWidth = 220;

// =============================================================================
// CONVENIENCE EDGE INSETS - Pre-built EdgeInsets for common use cases
// =============================================================================

/// Standard padding for dialog content
const EdgeInsets kDialogPadding = EdgeInsets.all(kSpacingXL);

/// Standard padding for panel sections
const EdgeInsets kPanelPadding = EdgeInsets.all(kSpacingM);

/// Tight padding for compact UI elements
const EdgeInsets kTightPadding = EdgeInsets.all(kSpacingS);

/// Horizontal padding for list items
const EdgeInsets kListItemPadding = EdgeInsets.symmetric(
  horizontal: kSpacingM,
  vertical: kSpacingS,
);

/// Header padding for section headers
const EdgeInsets kHeaderPadding = EdgeInsets.symmetric(
  horizontal: kSpacingM,
  vertical: kSpacingM,
);
