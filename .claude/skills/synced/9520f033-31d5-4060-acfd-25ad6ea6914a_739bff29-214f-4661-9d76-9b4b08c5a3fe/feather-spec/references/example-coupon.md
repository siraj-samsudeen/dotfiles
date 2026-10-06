Feature: Apply coupon

Workflow Context:
> "Customers ask for discounts. We have coupon codes but applying them 
> is manual - staff has to calculate the discount and adjust the total. 
> Sometimes they forget the maximum cap or apply expired coupons."
Pain points: Manual calculation, errors with caps, expired coupons accepted
Opportunity: Automate discount calculation with validation

Goal: Allow users to apply a coupon and reduce payable amount automatically

Scope
In: apply single coupon, remove coupon, recalculate totals
Out: stacking multiple coupons, referral points, admin coupon management

Dependencies
- Requires: cart system, product catalog
- Triggers: order total recalculation
- Blocked by: none

## CP-1: Apply Coupon

- WHEN user applies valid percentage coupon THE SYSTEM SHALL calculate discount and cap at maximum if specified
- WHEN user applies valid fixed-amount coupon THE SYSTEM SHALL subtract amount not exceeding eligible subtotal
- IF user enters non-existent coupon code THEN THE SYSTEM SHALL display "Coupon not found"
- IF user applies expired coupon THEN THE SYSTEM SHALL display "This coupon has expired"
- IF cart subtotal below minimum requirement THEN THE SYSTEM SHALL display "Minimum order of [amount] required"
- IF user applies coupon when one already active THEN THE SYSTEM SHALL display "Remove current coupon first"

**Examples:**
| Subtotal | Coupon | Discount | Total |
|----------|--------|----------|-------|
| $100 | "SAVE20" (20% off) | $20 | $80 |
| $100 | "SAVE20" (20% off, max $15) | $15 | $85 |
| $100 | "FLAT10" ($10 off) | $10 | $90 |
| $8 | "FLAT10" ($10 off) | $8 | $0 |

| Input | Result |
|-------|--------|
| "INVALIDCODE" | Error: "Coupon not found" |
| "EXPIRED2024" | Error: "This coupon has expired" |
| $30 cart + "MIN50" (min $50) | Error: "Minimum order of $50 required" |

## CP-2: Remove Coupon

- WHEN user removes applied coupon THE SYSTEM SHALL recalculate totals without discount

**Examples:**
| Before | Action | After |
|--------|--------|-------|
| $100 cart, "SAVE20" applied, total $80 | remove coupon | Total $100, no discount |

## CP-3: Auto-Recalculation

- WHEN cart items change while coupon is applied THE SYSTEM SHALL recalculate discount automatically
- WHILE coupon is applied THE SYSTEM SHALL show discount amount and adjusted total
- WHILE coupon is applied THE SYSTEM SHALL persist coupon until removed or checkout completes

**Examples:**
| Before | Action | After |
|--------|--------|-------|
| $100 cart, "SAVE20" (20%), $20 off | add $50 item | $150 cart, $30 off, total $120 |
| $100 cart, "SAVE20" (20%, max $15) | add $50 item | $150 cart, $15 off (capped), total $135 |

THE SYSTEM SHALL validate coupon code format: alphanumeric, 3-20 characters (ubiquitous)

Business Validation

BV1: Coupon must be active
BV2!: Coupon must not be expired (critical: revenue integrity)
BV3: Cart subtotal must meet coupon's minimum requirement
BV4: Only one coupon allowed per cart

Calculations

C1!: Percentage discount (critical: financial)
     discount = eligible_subtotal × discount_percentage
     If max_discount exists: cap at max_discount

C2: Fixed discount
    discount = fixed_amount
    Cannot exceed eligible_subtotal

C3: Eligible subtotal
    Sum of items matching eligible_categories
    If no categories specified: all items eligible

Permissions

Standard ownership (user can only modify own cart)

Input Validation

IV1: Coupon code must be non-empty
IV2: Coupon code format: alphanumeric, 3-20 characters

State Rules

S1: When cart items change, discount recalculates automatically
S2: Coupon persists until removed or checkout completes

Data Model

T1: coupons
- id (globally unique ID)
- code (text, unique)
- discount_type (one of: percentage, fixed)
- discount_value (number)
- max_discount (number, optional)
- min_subtotal (number)
- eligible_categories (list of text)
- active (yes/no)
- expires_at (date/time, optional)
- created_at, updated_at (date/time)

T2: cart_coupons
- id (globally unique ID)
- cart_id (reference to cart)
- coupon_id (reference to coupon)
- discount_applied (number)
- applied_at (date/time)

Related tables:

T3: carts (read/write)
- subtotal, discount, total (numbers)

T4: cart_items (read)
- price (number), category (text)

Out of Scope

- Stacking multiple coupons
- Referral points / loyalty rewards
- Admin coupon creation and management
- Coupon usage limits per user
