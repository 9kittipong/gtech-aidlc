# System Specification

## Inventory, AP/AR & Document Flow — No Chart of Accounts Design

**SYSTEM SPECIFICATION | NO COA DESIGN**

---

## สารบัญ (Table of Contents)

| # | หัวข้อ |
|---|--------|
| 01 | Core Engine & TX Log Structure |
| 02 | TX Type Master — ทุก Transaction |
| 03 | Document Flow — JOB_ORDER (Path A & B) |
| 04 | ฝั่งขาย — Sale, TEMP_DO, Invoice, CN |
| 05 | ฝั่งซื้อ — GR, Return, CN ทุกประเภท |
| 06 | คลัง & การปรับปรุงสินค้า |
| 07 | AP/AR — Open Item System |
| 08 | Mapping Table — Export ระบบบัญชี |
| 09 | Business Rules — กฎเหล็กทั้งระบบ |
| 10 | Alert System & Dev Notes |

---

## 01 Core Engine & TX Log Structure

### สถาปัตยกรรมระบบ — Transaction Log Engine

```
ฝั่งซื้อ              ฝั่งขาย              คลังสินค้า           AP/AR
PO/GR/Return/CN    SO/Invoice/Return/CN   Stock/Adjust/Transfer  Open Item System
        ↓                   ↓                    ↓                  ↓
        └───────────────────┴────────────────────┴──────────────────┘
                                    ↓
                    TRANSACTION LOG ENGINE
        TX_TYPE · มูลค่า · จำนวน · MA · Reference Chain · Timestamp · VAT · AP/AR
                                    ↓
        ┌───────────────────────────┴───────────────────────────┐
        ↓                                                       ↓
  รายงานภายใน                                          Export ระบบบัญชี
  Stock / COGS / AP Aging / Return Rate / PPV          Journal Entry ผ่าน Mapping Table
```

### TX Log — โครงสร้าง Fields บังคับทุก Transaction

#### Identity
- `tx_id` (PK)
- `tx_type` (ENUM)
- `tx_date`
- `period` (YYYY-MM)
- `status`: DRAFT | POSTED | VOIDED

#### Reference Chain
- `ref_po_id`
- `ref_gr_id`
- `ref_invoice_id` (Tax Invoice No)
- `ref_return_id`
- `ref_cn_id`
- `ref_jo_id`, `ref_do_id`
- `parent_tx_id` (VOID Ref)

#### Stock & Cost
- `item_id`, `warehouse_id`
- `qty` (+ เข้า / − ออก)
- `unit_cost`, `total_cost`
- `ma_before`, `ma_after`
- `stock_before`, `stock_after`
- `cogs_unit` (Sales TX)

#### AP / AR
- `vendor_id`, `customer_id`
- `ap_amount` (+/−)
- `ar_amount` (+/−)
- `ap_ar_status`: OPEN | PARTIAL | CLOSED

#### VAT
- `vat_type`: INPUT | OUTPUT | NONE
- `vat_rate`, `base_amount`
- `vat_amount`
- `tax_invoice_no`, `tax_period`

#### Variance & Audit
- `ppv_amount`, `cogs_adj_amount`
- `variance_reason`, `reason_code`
- `created_by`, `posted_by`
- `approved_by`, `voided_by`

---

### Moving Average (MA) — กฎการคำนวณ

> **MA = มูลค่าสินค้าคงเหลือทั้งหมด ÷ จำนวนสินค้าคงเหลือทั้งหมด**

| TX Type / Event | MA เปลี่ยน? | เหตุผล |
|-----------------|-------------|--------|
| รับสินค้า (GR_RECEIVE) | คำนวณใหม่ | มูลค่าและจำนวนเพิ่ม |
| รับสินค้าทดแทน (GR_REPLACEMENT) | คำนวณใหม่ | เหมือนรับสินค้าใหม่ |
| รับคืนจากลูกค้า (CN_SALES_RETURN) | คำนวณใหม่ | รับเข้าที่ COGS เดิม |
| CN_PRICE_ADJ (ซื้อ) | คำนวณใหม่ | ปรับมูลค่า Inventory |
| ADJ_COUNT_UP | คำนวณใหม่ | นับสต็อกเพิ่ม |
| ADJ_WRITEDOWN, ADJ_COST | คำนวณใหม่ | ปรับมูลค่าสินค้า |
| ADJ_TRANSFER (ปลายทาง) | คำนวณใหม่ | ปลายทางรับสินค้าเข้า |
| ขายสินค้าออก (SALE_INVOICE, TEMP_DO) | ไม่เปลี่ยน | ตัดที่ MA ปัจจุบัน |
| ส่งคืน Supplier (GR_RETURN) | ไม่เปลี่ยน | ตัดที่ MA ปัจจุบัน |
| CN_RETURN (ซื้อ) | ไม่เปลี่ยน | ปิด Clearing เท่านั้น ไม่แตะ Inventory |
| CN_SALES_PRICE / AP_CN_DEBT | ไม่เปลี่ยน | ไม่แตะ Inventory |
| ADJ_COUNT_DOWN, ADJ_WRITEOFF | ไม่เปลี่ยน | ตัดที่ MA ปัจจุบัน |

---

## 02 TX Type Master — ทุก Transaction ในระบบ

### TX Type Master — ฝั่งขาย

| TX Type | เมนู | Stock | AR | AP | MA | VAT | COGS | Approval |
|---------|-------|-------|-----|-----|-----|-----|------|----------|
| JOB_ORDER | ใบสั่งงาน | — | — | — | — | — | F | — |
| TEMP_DO | ใบส่งสินค้าชั่วคราว | ตัด | AR + | — | เดิม | OUTPUT | T | Cashier |
| INVOICE_FROM_DO | Invoice จาก DO | — | — | — | — | เอกสาร | F | Cashier |
| SALE_INVOICE | ใบเสร็จ(ตรง) | ตัด | AR + | — | เดิม | OUTPUT ใหม่ | T | Cashier |
| CN_SALES_RETURN | ใบลดหนี้รับคืน | เพิ่ม (COGS) | AR − | — | เดิม | OUTPUT− | T | Supervisor |
| CN_SALES_PRICE | ใบลดหนี้(ยอดหนี้) | — | AR − | — | เดิม | OUTPUT− | F | Manager |
| AR_RECEIVE | ใบรับชำระ | — | AR ปิด | — | เดิม | — | F | Cashier |
| AR_CN_DEBT | ใบลดหนี้ลูกหนี้(หนี้) | — | AR − | — | เดิม | OUTPUT− | F | Manager |
| AR_DN | ใบเพิ่มหนี้ลูกหนี้ | — | AR + | — | — | OUTPUT | F | Manager |

### TX Type Master — ฝั่งซื้อ

| TX Type | เมนู | Stock | AP | MA | VAT | Approval |
|---------|-------|-------|-----|-----|-----|----------|
| GR_RECEIVE | ใบรับสินค้า | เพิ่ม | AP + | ใหม่ | INPUT | Store |
| GR_RETURN | ใบส่งคืน | ลด(MA) | Clearing | เดิม | — | Supervisor |
| GR_REPLACEMENT | รับทดแทน | เพิ่ม(ทุนเดิม) | — | ใหม่ | INPUT | Store |
| CN_RETURN | ใบลดหนี้(จากส่งคืน) | ไม่แตะ | AP − | เดิม | INPUT− | Manager |
| CN_PRICE_ADJ | ใบลดหนี้ตามใบเสร็จ | ลด(บางส่วน) | AP − | เดิม | INPUT− | Manager |
| AP_CN_DEBT | ใบลดหนี้(ยอดหนี้) | ไม่แตะ | AP − | เดิม | INPUT− | Manager |
| AP_PAYMENT | ใบจ่ายชำระ | — | AP ปิด | เดิม | — | Manager |
| AP_DN | ใบเพิ่มหนี้เจ้าหนี้ | — | AP + | ใหม่ | INPUT | Manager |
| AP_DN_REF | ใบเพิ่มหนี้ตามใบเสร็จ | เพิ่ม | AP + | ใหม่ | INPUT | Manager |

### TX Type Master — คลัง / ปรับปรุงสินค้า / อื่นๆ

| TX Type | ความหมาย | Stock | MA | Approval | เอกสาร |
|---------|----------|-------|-----|----------|--------|
| ADJ_COUNT_UP | ตรวจนับ/ปรับปรุง(เพิ่ม) | เพิ่ม | ใหม่ | Threshold | ใบนับสต็อก |
| ADJ_COUNT_DOWN | ตรวจนับ/ปรับปรุง(ลด) | ลด(MA) | ลด | Threshold | ใบนับสต็อก |
| ADJ_WRITEDOWN | ลดมูลค่าสินค้า | เดิม/มูลค่าลด | เดิม | CFO | ใบประเมิน NRV |
| ADJ_WRITEOFF | ตัดจำหน่าย | ลด(MA) | เดิม | CFO | ใบอนุมัติ+หลักฐาน |
| ADJ_TRANSFER | โอนย้ายสินค้า | ย้าย WH | ปลายทาง↑ | Supervisor | ใบโอน |
| ADJ_RECLASS | จัดประเภทใหม่ | ย้าย Item | Item ใหม่ | Supervisor | ใบ Reclass |
| ADJ_COST | ปรับต้นทุน | เดิม/มูลค่า± | ใหม่ | CFO | เอกสาร Landed Cost |
| SUPPLY_ISSUE | เบิกวัสดุ | ลด(MA) | เดิม | Supervisor | ใบเบิก |
| WHT_RECORD | ภาษีหัก ณ ที่จ่าย | — | — | Manager | ใบหักภาษี |
| CHEQUE_RECEIVE | รับเช็ค | — | — | Cashier | ใบรับเช็ค |
| EXPENSE_RECORD | บันทึกค่าใช้จ่าย | — | — | Manager | ใบค่าใช้จ่าย |
| *_VOID | ยกเลิก TX ใดๆ | กลับค่า | คำนวณใหม่ | Manager+ | ต้องมีเหตุผล |

---

## 03 Document Flow — JOB_ORDER (Path A & B)

### JOB_ORDER — 2 เส้นทาง (Path A & Path B)

#### PATH A — ผ่านใบส่งสินค้าชั่วคราว (TEMP_DO)

```
ใบสั่งงาน          →    ใบส่งชั่วคราว    →    Invoice
JOB_ORDER               TEMP_DO               INVOICE_FROM_DO

ไม่ตัด Stock             ตัด Stock              เอกสารภาษีเท่านั้น
ไม่มี AR                 บันทึก AR              ไม่ตัด Stock
                          VAT                    ไม่สร้าง AR
```

#### PATH B — Invoice ตรงจากใบสั่งงาน (ไม่ผ่าน TEMP_DO)

```
ใบสั่งงาน          →    (ไม่มี TEMP_DO)   →    ใบเสร็จ
JOB_ORDER                                       SALE_INVOICE

ไม่ตัด Stock             —                      ตัด Stock
ไม่มี AR                 —                      บันทึก AR
                                                 VAT + Invoice
```

### Path A — TEMP_DO: Logic ละเอียด

#### Step 1: JOB_ORDER
- ไม่สร้าง TX Log
- `has_temp_do = false`
- `invoice_id = null`
- status: OPEN → IN_PROGRESS → DONE

#### Step 2: TEMP_DO — ทำงานเหมือน SALE_INVOICE
- ตัด Stock ที่ MA ณ วันออก TEMP_DO
- บันทึก `cogs_unit` ไว้ใน TX (ใช้ตอน Return)
- AR + = base_amount + vat_amount
- VAT OUTPUT บันทึก tax_period
- อัปเดต JOB_ORDER: `has_temp_do=true`, `temp_do_id=DO-xxx`

#### Step 3: INVOICE_FROM_DO — เอกสารภาษีเท่านั้น
- ระบบตรวจ `has_temp_do=true` → TX Type = INVOICE_FROM_DO
- `qty=0`, `total_cost=0` (ไม่ตัด Stock)
- `ar_amount=0` (ไม่สร้าง AR ใหม่)
- ออก `tax_invoice_no` อย่างเป็นทางการ
- สืบทอด VAT จาก TEMP_DO TX เดิม

### Validation Logic — ตรวจสอบก่อนสร้าง Invoice ทุกครั้ง

```pseudocode
function createInvoice(jo_id):
    jo = getJobOrder(jo_id)
    
    // Check 1: JOB_ORDER ต้อง DONE
    if jo.status != 'DONE': throw 'ใบสั่งงานยังไม่เสร็จ'
    
    // Check 2: มี Invoice แล้วหรือยัง
    if jo.invoice_id != null: throw 'มีใบเสร็จแล้ว ห้ามออกซ้ำ'
    
    // Check 3: มี TEMP_DO หรือไม่
    if jo.has_temp_do == true:
        tx_type = 'INVOICE_FROM_DO'        // ← เอกสารภาษีเท่านั้น
        stock_change = 0, ar_change = 0    // ← ไม่แตะ Stock/AR
        vat_ref = getTempDoTx(jo.temp_do_id).vat_amount
    else:
        tx_type = 'SALE_INVOICE'           // ← ทำครบในก้อนเดียว
        stock_change = qty × ma_current    // ← ตัด Stock
        ar_change = base + vat             // ← สร้าง AR
```

> ⛔ **ห้ามเด็ดขาด:** ระบบต้องตรวจ `has_temp_do` ก่อนทุกครั้ง — ห้ามให้ผู้ใช้เลือก TX Type เองเด็ดขาด

### JOB_ORDER Status — เอกสารที่อนุญาตแต่ละสถานะ

| Status JOB_ORDER | ความหมาย | ออก TEMP_DO | ออก Invoice ตรง | ออก Invoice จาก DO |
|------------------|----------|-------------|-----------------|-------------------|
| OPEN | ยังทำงานไม่เสร็จ | ไม่ได้ | ไม่ได้ | ไม่ได้ |
| IN_PROGRESS | กำลังซ่อม/ให้บริการ | ไม่ได้ | ไม่ได้ | ไม่ได้ |
| DONE — ไม่มี TEMP_DO, ไม่มี Invoice | งานเสร็จ รอออกเอกสาร | ทำได้ | ทำได้ | ไม่ได้ |
| DONE + มี TEMP_DO (ยังไม่มี Invoice) | ส่งของแล้ว รอออก Invoice | ไม่ได้ | ไม่ได้ | ทำได้ |
| DONE + มี Invoice แล้ว | ปิดสมบูรณ์ | ไม่ได้ | ไม่ได้ | ไม่ได้ |

> ⚠️ **Alert:** JOB_ORDER ที่ DONE แต่ไม่มี Invoice > 24 ชม. ต้องแจ้งเตือน Supervisor

> ⚠️ **Alert:** TEMP_DO ที่ไม่มี Invoice > 7 วัน ต้องแจ้งเตือน Manager

> ❌ **Error:** ห้าม TEMP_DO มากกว่า 1 ใบต่อ JOB_ORDER เด็ดขาด

---

## 04 ฝั่งขาย — Sale, TEMP_DO, Invoice, CN

### ฝั่งขาย — เงื่อนไขแต่ละ TX Type

#### SALE_INVOICE / TEMP_DO
- ตัด Stock ที่ MA ณ วันออก TX
- บันทึก `cogs_unit` ใน TX — ใช้ตอน Return
- AR + = base_amount + vat_amount
- VAT OUTPUT — บันทึก `tax_invoice_no`
- MA ไม่เปลี่ยน (สินค้าออก ไม่ใช่เข้า)
- **Validation:** Stock พอก่อน POST

#### CN_SALES_RETURN — รับคืนสินค้า
- บังคับอ้างอิง Tax Invoice เดิม
- ดึง `cogs_unit` จาก SALE_INVOICE/TEMP_DO TX
- ตรวจสภาพก่อนรับเข้า Stock (ดี/เสีย/เสียหมด)
- ถ้าของดี: รับที่ cogs_unit → MA คำนวณใหม่
- ถ้าเสียหาย: Inventory(NRV) + Loss
- ถ้าเสียหมด: Loss เท่านั้น ไม่รับเข้า Stock
- AR − / Revenue − / VAT OUTPUT −

#### CN_SALES_PRICE — ลดราคา/ส่วนลด
- ไม่แตะ Inventory เด็ดขาด — สินค้าอยู่ที่ลูกค้า
- AR − / Revenue − / VAT OUTPUT −
- MA ไม่เปลี่ยน
- บังคับอ้างอิง Tax Invoice เดิม
- ต้องผ่าน Manager Approval
- ระบุเหตุผลบังคับ

#### CN อ้างอิง Invoice จาก TEMP_DO
- `tax_invoice_no` มาจาก INVOICE_FROM_DO
- `cogs_unit` ต้องดึงจาก TEMP_DO TX (ไม่ใช่ Invoice)
- ระบบต้อง Traverse: Invoice → TEMP_DO → cogs_unit
- **Validation:** จำนวนคืน ≤ จำนวนใน TEMP_DO

---

## 05 ฝั่งซื้อ — GR, Return, CN ทุกประเภท

### ฝั่งซื้อ — GR & Return

#### GR_RECEIVE — ใบรับสินค้า (Root Document)
- Root Document — เก็บ `tax_invoice_no` บังคับ
- Stock + = qty / MA คำนวณใหม่ทันที
- AP + = (unit_cost × qty) + VAT
- Landed Cost: กระจายเพิ่ม unit_cost ก่อน POST
- 3-Way Match: PO + GR + Invoice ก่อนบันทึก AP
- **Validation:** PO ต้องมีสถานะ Approved

#### GR_RETURN — ใบส่งคืนสินค้า
- Stock − = qty × MA ณ วันคืน (ไม่ใช่ GR Cost)
- เปิด `gr_ir_return_clearing` = qty × ma_before
- MA ไม่เปลี่ยน
- เก็บ `ref_gr_id` เพื่อให้ CN Inherit ต่อ
- **Validation:** Stock ≥ qty ที่คืน
- **Validation:** GR ที่อ้างอิงต้องยังไม่ถูกคืนหมด

#### GR_REPLACEMENT — รับสินค้าทดแทน
- Invoice 0 บาท → ไม่มี AP เกิดขึ้น
- รับเข้า Stock ที่มูลค่าจาก GR/IR Return Clearing
- MA คำนวณใหม่
- ปิด `gr_ir_return_clearing` อัตโนมัติ

> ⚠️ Invoice 0 = ไม่มี VAT → ควรให้ Supplier ออก Invoice ตามมูลค่า

#### PPV (Purchase Price Variance)
- PPV = GR/IR Clearing Balance − CN Amount
- เกิดเมื่อ MA ณ วันคืน ≠ ราคาใน Invoice
- บันทึกใน `ppv_amount` ของ TX อัตโนมัติ
- Export เป็น Dr. PPV Account ใน Mapping
- PPV Report แยกรายสินค้า/Vendor วิเคราะห์ได้

### ฝั่งซื้อ — CN ทั้ง 3 ประเภท (ต่างกันโดยสิ้นเชิง)

#### AP_CN_DEBT — ใบลดหนี้ (ยอดหนี้เท่านั้น)
- **ไม่เกี่ยวกับ Inventory เลย**
- AP − = cn_amount / VAT INPUT −
- MA ไม่เปลี่ยน / Stock ไม่เปลี่ยน
- ใช้สำหรับ: ส่วนลด, ค่าปรับ, ค่าธรรมเนียม
- บังคับอ้างอิง Invoice เดิม (ไม่ต้องอ้างอิง GR)
- ต้องผ่าน Manager Approval + ระบุเหตุผล

#### CN_RETURN — ใบลดหนี้ (จากส่งคืน)
- Inherit `ref_gr_id` จาก GR_RETURN อัตโนมัติ
- Inherit `tax_invoice_no` จาก GR_RECEIVE อัตโนมัติ
- **ไม่แตะ Inventory เลย**
- AP − = ราคาใน Invoice (unit_cost × qty)
- PPV = GR/IR Clearing − AP ที่ลด
- ปิด `gr_ir_return_clearing`
- VAT INPUT −

#### CN_PRICE_ADJ — ใบลดหนี้ตามใบเสร็จ (ราคาผิด)
- บังคับอ้างอิง GR_RECEIVE เดิม
- ตรวจ Stock คงเหลือ ณ วันที่ CN มา
- ส่วนที่เหลือใน Stock → Inventory ลด + MA ใหม่
- ส่วนที่ขายไปแล้ว → `cogs_adj_amount`
- AP − = cn_amount / VAT INPUT −
- ห้าม POST ย้อนหลัง Period ปิดแล้ว

> ⛔ **CN ทั้ง 3 ประเภทต้องเป็น TX Type คนละตัว — Dev ห้าม Combine Logic รวมกัน**

---

## 06 คลัง & การปรับปรุงสินค้า

### การปรับปรุงสินค้า — Sub-type และ Logic

#### ADJ_COUNT_UP / DOWN — นับสต็อก
- Freeze Stock ก่อนนับ — ห้ามรับ/จ่ายระหว่างนับ
- UP: Stock+ → MA คำนวณใหม่
- DOWN: Stock− ที่ MA ปัจจุบัน → MA ไม่เปลี่ยน
- Approval ตาม Threshold มูลค่า
- บันทึก Reason Code บังคับ

#### ADJ_WRITEDOWN — ลดมูลค่า
- จำนวนคงเดิม มูลค่าลดลง → MA ลด
- ใช้ NRV = ราคาขาย − ค่าขาย
- Direct: ปรับ Inventory ตรง MA ลดทันที
- Allowance: ตั้งสำรอง MA เดิม (รีวิวรายปี)
- Reverse ได้แต่ ≤ ต้นทุนเดิม — CFO Approve

#### ADJ_WRITEOFF — ตัดจำหน่าย
- Stock− ที่ MA ปัจจุบัน → MA ไม่เปลี่ยน
- บันทึก Loss on Write-off
- มีซาก: Dr. Salvage Inventory + Loss
- มีประกัน: Dr. Insurance Receivable + Loss
- บังคับแนบหลักฐานการทำลาย — CFO Approve

#### ADJ_TRANSFER — โอนย้าย
- ต้นทาง Stock− / ปลายทาง Stock+
- ระหว่างโอน: IN_TRANSIT Stock
- ต้นทาง MA ไม่เปลี่ยน
- ปลายทาง MA คำนวณใหม่จากของเดิม+รับเข้า
- ต้องมีใบโอนย้าย — Supervisor Approve

#### ADJ_RECLASS — จัดประเภทใหม่
- มูลค่ารวมต้องเท่าเดิมเสมอ — ห้ามมี Gain/Loss
- Item เก่า Stock− / Item ใหม่ Stock+
- MA ของ Item ใหม่คำนวณใหม่
- รองรับ: เปลี่ยน UOM, แยก Lot, รวม Lot
- UOM: กำหนด Conversion Factor ก่อน

#### ADJ_COST — ปรับต้นทุน
- มูลค่า Inventory เปลี่ยน จำนวนคงเดิม
- MA คำนวณใหม่ทันที
- ใช้สำหรับ Landed Cost เพิ่มเติม
- CFO Approve บังคับ
- Export: Dr. Inventory / Cr. Cost Variance

### การตรวจนับสต็อก — Flow และ Approval Threshold

```
Freeze Stock → นับของจริง → บันทึกผลนับ → เปรียบเทียบ → Approve ส่วนต่าง → POST Adjustment → Unfreeze Stock
```

| มูลค่าส่วนต่าง | Approval ที่ต้องการ | เอกสารเพิ่มเติม |
|----------------|-------------------|-----------------|
| น้อยกว่า 1,000 บาท | Warehouse Supervisor | ใบนับสต็อก |
| 1,000 – 10,000 บาท | ผู้จัดการ Warehouse | ใบนับ + ชี้แจงสาเหตุ |
| 10,000 – 100,000 บาท | CFO | รายงานสอบสวน |
| มากกว่า 100,000 บาท | กรรมการ | รายงานสอบสวน + Audit |

> ⛔ ห้าม POST Adjustment โดยไม่ผ่าน Approval

> ⚠️ ส่วนต่างสูงผิดปกติต้องสอบสวนสาเหตุก่อน (โจรกรรม/ความผิดพลาด/เสียหาย)

> ❌ **Alert:** Stock ติดลบ = ระบบผิดพลาด → Throw Error ก่อน POST ทุกกรณี

---

## 07 AP/AR — Open Item System

### AP/AR Open Item — หลักการและ Flow

> **หลักการ:** ทุก TX ที่สร้าง AP หรือ AR จะมีสถานะ OPEN → PARTIAL → CLOSED

#### AR

| TX Type | AR | ความหมาย | Approval |
|---------|-----|----------|----------|
| SALE_INVOICE / TEMP_DO | AR OPEN | เปิด AR Open Item | Cashier |
| ใบวางบิล (AR_BILLING) | Document เท่านั้น | ไม่สร้าง TX ใหม่ | — |
| AR_RECEIVE | AR ปิด | Match กับ Invoice OPEN | Cashier |
| AR_REFUND | AR เปิดใหม่ | คืนเงินที่รับไปแล้ว | Manager |
| AR_CN_DEBT | AR − | ลดยอดหนี้ ไม่รับของคืน | Manager |
| CN_SALES_RETURN | AR − | รับของคืน ดึง COGS เดิม | Supervisor |
| AR_DN / AR_DN_REF | AR + | เพิ่มยอดหนี้ | Manager |

#### AP

| TX Type | AP | ความหมาย | Approval |
|---------|-----|----------|----------|
| GR_RECEIVE | AP OPEN | เปิด AP Open Item | Store |
| AP_PAYMENT | AP ปิด | Match กับ GR ที่ OPEN | Manager |
| CN_RETURN | AP − | ปิด GR/IR Clearing + PPV | Manager |
| CN_PRICE_ADJ | AP − | ปรับ Inventory + MA | Manager |
| AP_CN_DEBT | AP − | ยอดหนี้เท่านั้น ไม่แตะ Inventory | Manager |
| AP_DN / AP_DN_REF | AP + | เพิ่มยอดหนี้ | Manager |

---

## 08 Mapping Table — Export ระบบบัญชี

### Mapping Table — Master Data สำหรับ Export

> TX Log ไม่มีผังบัญชี → Mapping Table แปลง TX Type เป็น Dr/Cr Account Code ของระบบบัญชีปลายทาง

#### โครงสร้าง accounting_mapping table
- `mapping_id` (PK), `accounting_system`
- `company_id` — รองรับ Multi-company
- `tx_type` (ENUM) — TX Type ของระบบ
- `sub_condition` — เงื่อนไขพิเศษ เช่น ITEM_GROUP
- `line_seq`, `side`: DR | CR
- `account_code`, `account_name` — ของระบบบัญชีปลายทาง
- `amount_source` — ฟิลด์ใน TX ที่ดึงมูลค่า
- `effective_date` — เปลี่ยน Mapping ได้ไม่กระทบ TX เก่า

#### Admin UI ที่ต้องมี
- CRUD Mapping ต่อ TX Type ต่อ Company
- Preview Journal Entry ก่อน Save
- Test Export ด้วย TX จริงก่อน Go-Live
- Version History ของ Mapping (Audit)
- รองรับ Multiple Accounting Systems
- Effective Date — เปลี่ยนได้ไม่กระทบ TX เก่า
- Alert: TX Type ที่ไม่มี Mapping ก่อน Export

#### ตัวอย่าง Mapping

| TX Type | Seq | Side | Account Code | Amount Source |
|---------|-----|------|--------------|--------------|
| TEMP_DO | 1 | DR | 1100 ลูกหนี้ | ar_amount |
| TEMP_DO | 2 | CR | 4100 รายได้ | base_amount |
| TEMP_DO | 3 | DR/CR | 5100 COGS / 1410 Inventory | total_cost |
| INVOICE_FROM_DO | — | — | ไม่มี Journal Entry | formal_doc=true |
| CN_RETURN | 1 | DR | 2100 เจ้าหนี้ | ap_amount |
| CN_RETURN | 2 | DR | 5210 PPV | ppv_amount |
| CN_RETURN | 3 | CR | 1420 GR/IR Return | qty × ma_before |
| AP_CN_DEBT | 1 | DR | 2100 เจ้าหนี้ | ap_amount |
| AP_CN_DEBT | 2 | CR | 4200 ส่วนลดรับ | base_amount |
| ADJ_WRITEOFF | 1 | DR | 5310 Loss on Write-off | qty × ma_before |
| ADJ_WRITEOFF | 2 | CR | 1410 สินค้าคงเหลือ | qty × ma_before |

---

## 09 Business Rules — กฎเหล็กทั้งระบบ

### กฎเหล็ก — ห้ามเด็ดขาด (Dev Must NOT Implement)

| FORBIDDEN — ห้ามเด็ดขาด | เหตุผล |
|--------------------------|--------|
| ห้าม UPDATE qty/cost ใน TX ที่ POSTED แล้ว | TX ที่ POST แล้วต้องเป็น Immutable — ใช้ VOID แทน |
| ห้ามใช้ GR Cost แทน MA ตอนส่งคืน | GR Cost ถูก Blend เข้า MA แล้ว ไม่มีตัวตนแยก |
| ห้าม DELETE TX ใดๆ ทั้งหมด | ทุก TX ต้องอยู่ในระบบตลอดกาล รวม VOIDED |
| ห้าม Override Journal ใน Mapping Table | Mapping กำหนด Logic ทั้งหมด ห้ามแก้ Manual |
| ห้าม Re-calculate MA ย้อนหลัง | MA ที่เกิดขึ้นแล้วถือว่าถูกต้อง ณ เวลานั้น |
| ห้ามให้ผู้ใช้เลือก TX Type เอง | ระบบต้องกำหนด TX Type อัตโนมัติจาก Document Context |
| ห้าม POST TX ใน Period ที่ปิดแล้ว | Period Lock ต้องเช็คก่อน POST ทุก TX ไม่มีข้อยกเว้น |
| ห้ามสร้าง SALE_INVOICE จาก JO ที่มี TEMP_DO | จะทำให้ตัด Stock ซ้ำและ AR เกิดสองครั้ง |
| ห้ามแตะ Inventory ใน CN_RETURN (ซื้อ) | ของออกไปใน GR_RETURN แล้ว CN แค่ปิด Clearing |
| ห้าม Stock ติดลบ | ต้อง Throw Error ก่อน POST — ไม่อนุญาตให้ผ่าน |

### กฎบังคับ — ต้อง Implement ทุกข้อ

| MANDATORY — บังคับทำทุกข้อ | รายละเอียด |
|----------------------------|-----------|
| VOID = สร้าง TX ใหม่ค่าตรงข้าม | `parent_tx_id` อ้างอิง TX เดิม สถานะ TX เดิม = VOIDED |
| Validate Reference Chain ก่อน POST | CN ต้องมี Invoice, Return ต้องมี GR Reference |
| MA คำนวณใหม่ใน Atomic Transaction | ถ้า POST ล้มเหลวระหว่างกลาง ต้อง Rollback ทั้งก้อน |
| เก็บ ma_before/ma_after ทุก TX | ใช้สำหรับ Audit Trail และคำนวณ PPV |
| Approval Workflow ตาม TX Type | ทุก TX ที่ต้อง Approve ห้าม POST โดยตรง |
| Audit Trail ทุก field change | Log who/when/what ทุกการเปลี่ยนแปลง |
| เก็บ cogs_unit ใน SALE_INVOICE/TEMP_DO | ใช้ตอน Sales Return ดึง COGS เดิม |
| Period Lock ก่อน Allow POST | เช็ค period Status ก่อน POST ทุก TX ไม่มีข้อยกเว้น |
| Lock CN Type หลัง POST | ห้าม UPDATE tx_type หลัง POSTED |
| Alert TEMP_DO ค้างนาน | TEMP_DO > 7 วัน ไม่มี Invoice ต้องแจ้งเตือน |

---

## 10 Alert System & Dev Notes

### Alert System — สัญญาณเตือนทั้งระบบ

#### ERROR
- Stock ติดลบ — Throw Error ก่อน POST
- CN_RETURN แตะ Inventory Fields
- INVOICE_FROM_DO ตัด Stock
- SALE_INVOICE จาก JO ที่มี TEMP_DO แล้ว
- Invoice ออกซ้ำจาก JO เดิม
- POST ใน Period ที่ปิดแล้ว

#### WARNING
- TEMP_DO ค้างเกิน 7 วัน ไม่มี Invoice
- GR/IR Return Clearing ค้างเกิน 30 วัน
- JO DONE ไม่มี Invoice > 24 ชม.
- PPV เกิน Threshold ที่กำหนด
- MA เปลี่ยนผิดปกติ (ลด/เพิ่ม > X%)
- Return Rate สูงผิดปกติ
- Damaged Stock ค้างนาน

#### INFO
- AP Due Soon (ใกล้ครบกำหนด)
- AR Overdue
- Stock ต่ำกว่า Reorder Point
- Stock ใกล้หมดอายุ (Serial/DOT)
- Approval ค้างนาน > N ชั่วโมง
- Mapping Table ไม่ครบทุก TX Type
- Export Journal ล้มเหลว

---

### Dev Notes — สิ่งที่ต้องตัดสินใจก่อน Sprint แรก

#### Q1: TEMP_DO ใช้ AR_CLEARING Field อะไร?
- **Option A:** `ar_clearing_amount` ใน TX Log
- **Option B:** ตาราง `temp_do_clearing` แยก
- → **แนะนำ Option A:** ง่ายกว่า Query ได้ตรง

#### Q2: ADJ_WRITEDOWN — Direct หรือ Allowance?
- **Option A:** Direct → MA ลดทันที
- **Option B:** Allowance → MA เดิม แสดงแยก B/S
- → **แนะนำ Option A** สำหรับระบบ Perpetual

#### Q3: Approval Workflow — Internal หรือ External?
- **Option A:** In-app workflow (สร้างเอง)
- **Option B:** External (เช่น email approval)
- → ขึ้นกับ Timeline และ Resource

#### Q4: Export Journal — Real-time หรือ Batch?
- **Option A:** Real-time Webhook ทุก POST
- **Option B:** Batch รายวัน/รายชั่วโมง
- → **แนะนำ Batch** ป้องกัน Dependency ล้มเหลว

#### Q5: Multi-currency รองรับไหม?
- ถ้ามี: ต้องเก็บ `exchange_rate` ใน TX
- MA คำนวณใน Local Currency เสมอ
- Realized/Unrealized FX Gain/Loss

#### Q6: Stock Count — Full Freeze หรือ Cycle?
- **Option A:** Full Freeze ทั้ง Warehouse
- **Option B:** Cycle Count ทีละ Location
- → Cycle Count ซับซ้อนกว่า แต่ไม่หยุดงาน

---

### Dev Notes — Performance & Database Design

#### Database Index ที่ต้องมี
- `item_id` + `warehouse_id` + `tx_date` (Composite)
- `tx_type` + `period` (ใช้สำหรับ Report)
- `vendor_id` (AP Queries)
- `customer_id` (AR Queries)
- `status` (Filter POSTED เท่านั้น)
- `ref_jo_id`, `ref_do_id` (JO Flow)
- `tax_period` + `vat_type` (VAT Report)
- `parent_tx_id` (VOID Lookup)

#### Performance Considerations
- Stock Balance = SUM ทุก TX → ทำ Daily Snapshot Cache
- MA = `stock_after`/`total_cost` ล่าสุด ไม่ต้อง SUM ทุก TX
- AR/AP Aging → Materialized View หรือ Cache
- Report Query ควรแยก Read DB จาก Write DB
- TEMP_DO Report: JOIN เฉพาะ TEMP_DO ที่ `invoice_issued=false`
- GR/IR Clearing: JOIN GR_RETURN LEFT JOIN CN_RETURN
- Period Lock: Cache `period_status` ไว้ใน Redis/Memory
- TX Log อาจเติบโตเร็ว → Partition by `tx_date` รายเดือน

---

## System Specification Summary

| หัวข้อ | สรุป |
|--------|------|
| TX Type Master | ทุก Transaction มี Type กำหนด Logic อัตโนมัติ |
| Moving Average Perpetual | MA ใหม่เฉพาะตอนรับสินค้าเข้า ห้าม Re-calculate ย้อนหลัง |
| JOB_ORDER 2 Path | ตรวจ `has_temp_do` ก่อนออก Invoice ทุกครั้ง |
| CN 3+2 ประเภท | แตกต่างกันที่ Inventory Impact ต้องเป็น TX Type คนละตัว |
| Mapping Table | Master Data แปลง TX เป็น Journal Entry ไม่ต้องมีผังบัญชี |
| TX Log Immutable | ห้าม DELETE/UPDATE หลัง POST ใช้ VOID เท่านั้น |

---

*v1.0 | System Spec — No COA Design*
