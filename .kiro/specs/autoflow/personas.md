# Personas

## Overview
This system serves 6 distinct user types with different responsibilities and approval levels in the inventory and document flow process.

---

## Cashier (พนักงานแคชเชียร์)

**Role**: Front-line sales operator

**Goals**:
- Process sales transactions quickly and accurately
- Issue invoices and receive payments without delays
- Handle TEMP_DO for Job Orders that need immediate delivery

**Pain Points**:
- Complex document flows slow down customer service
- Unclear which path (TEMP_DO vs direct Invoice) to use for each Job Order
- Need to verify stock availability before committing to sales

**User Journey**: Receive Job Order → Check stock → Issue TEMP_DO or Invoice → Collect payment (AR_RECEIVE)

**Implications**: Needs streamlined UI for sales flow, clear visual indicators for JO status, quick stock lookup, minimal clicks for common operations

---

## Store Staff (พนักงานคลัง)

**Role**: Warehouse receiving and stock management operator

**Goals**:
- Receive goods accurately with correct quantities and costs
- Maintain stock accuracy through proper GR documentation
- Ensure tax invoice numbers are recorded for every receipt

**Pain Points**:
- Manual data entry errors in quantities and costs affect MA calculations
- Need to match PO with physical goods received
- Landed cost allocation is complex

**User Journey**: Receive PO notification → Physical count → Create GR_RECEIVE → Record tax invoice → Confirm stock update

**Implications**: Needs barcode/item lookup, PO reference auto-fill, clear MA impact preview, validation before POST

---

## Supervisor (หัวหน้างาน)

**Role**: Operational oversight and first-level approver

**Goals**:
- Approve returns and transfers promptly
- Monitor stock movements for anomalies
- Ensure stock count accuracy

**Pain Points**:
- Approval queue can pile up during busy periods
- Need visibility into why returns are happening
- Stock transfer tracking between warehouses is manual

**User Journey**: Review pending approvals → Verify documentation → Approve/Reject → Monitor alerts

**Implications**: Needs approval dashboard, reason code visibility, stock movement summary, alert notifications for pending items

---

## Manager (ผู้จัดการ)

**Role**: Financial oversight and high-level approver

**Goals**:
- Approve Credit Notes and AP payments with proper documentation
- Monitor AP/AR aging and cash flow
- Ensure business rules are followed across all operations

**Pain Points**:
- CN approvals require understanding the full reference chain (Invoice → GR → Return)
- AP payment matching needs visibility into open items
- Need to catch unusual patterns (high return rates, PPV spikes)

**User Journey**: Review CN/Payment requests → Verify reference chain → Approve → Review AP/AR reports

**Implications**: Needs reference chain visualization, AP/AR aging view, CN type differentiation in UI, batch approval capability

---

## CFO (ผู้บริหารการเงิน)

**Role**: Financial controller and highest-level approver

**Goals**:
- Approve write-downs, write-offs, and cost adjustments
- Ensure inventory valuation accuracy
- Oversee period closing and financial reporting

**Pain Points**:
- Write-down/write-off decisions need NRV calculations and supporting evidence
- Cost adjustments affect MA across the system
- Period closing requires all pending items resolved

**User Journey**: Review high-value adjustment requests → Verify NRV/evidence → Approve → Review financial impact → Close period

**Implications**: Needs financial impact preview before approval, NRV calculation display, period status dashboard, audit trail access

---

## Admin (ผู้ดูแลระบบ)

**Role**: System configuration and master data management

**Goals**:
- Configure TX Type behaviors and validation rules
- Manage user roles and approval thresholds
- Maintain item master, warehouse, vendor, and customer data

**Pain Points**:
- Configuration changes can have cascading effects on business logic
- Need to test changes before they affect live operations
- Master data quality directly impacts all transactions

**User Journey**: Configure system settings → Test in sandbox → Deploy to production → Monitor for issues

**Implications**: Needs configuration UI with preview/test capability, master data CRUD with validation, role-based access control management, audit log for config changes

---

## Design Implications

- **Architecture**: Role-based access control (RBAC) with 6 distinct permission levels; approval routing based on TX type and value thresholds
- **UI/UX**: Different dashboard views per role; Cashier needs speed-optimized flow, Manager needs analytical views, CFO needs financial impact previews
- **Data & Privacy**: Users see only data relevant to their role; audit trail tracks all actions by user; sensitive financial data (costs, margins) restricted to Manager+ roles
