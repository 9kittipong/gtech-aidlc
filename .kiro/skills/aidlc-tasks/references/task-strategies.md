# Task Breakdown Strategies

## Vertical Slice (Recommended)
Each task delivers a complete user-facing feature across all layers.
**Pros**: Delivers value incrementally, easier to demo, clear progress
**Cons**: May touch multiple layers, harder to parallelize

## Layer-by-Layer
Tasks organized by technical layer.
**Pros**: Clear technical separation, easier to parallelize
**Cons**: No user value until all layers complete, integration risk

## Feature-by-Feature
Tasks organized by functional area.
**Pros**: Clear feature boundaries, easier to prioritize
**Cons**: May have dependencies between features

## Component-First
Build shared components before features.
**Pros**: Reusable components, consistent patterns
**Cons**: Risk of over-engineering, delayed user value

## Task Sizing Rules
- Break down tasks so they can be completed in **1-2 days or less**
- Good sizes: single CRUD operation, one UI component, specific API endpoint, unit tests for a module
- Too large: "Implement entire authentication system", "Build complete user management"
