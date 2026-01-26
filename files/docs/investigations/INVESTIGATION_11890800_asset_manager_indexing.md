# Investigation Report

## Automated Asset Manager Indexing

**Ticket:** 11890800

**Status:** Completed

**Date:** 2025-01-26

---

## 1. Summary

Investigation into why Asset Manager indexing is not fully automated and requires manual configuration steps. Discovered that multiple manual steps are needed to achieve full visibility of tokens and balances.

---

## 2. Problem Statement

As a Kaleido developer, I expected Asset Manager to automatically index all blockchain events and display them without manual intervention. However, there is inconsistency between what exists on-chain and what is visible in Kaleido.

---

## 3. Investigation Findings

### 3.1 Asset Manager Indexing Components

Asset Manager relies on multiple components for indexing:

| Component | Function | Auto-configured? |
|-----------|----------|------------------|
| FFI (FireFly Interface) | Contract ABI registration | NO - manual |
| Contract API | REST API for contract | NO - manual |
| FFListener | Event subscription | Partially - requires FFI |
| Address Tracking | Track specific addresses | NO - manual |

### 3.2 Root Causes of Incomplete Indexing

#### Cause 1: FFI Registration Required

- New smart contracts require FireFly Interface (FFI) registration
- Without FFI, Asset Manager cannot decode contract events
- Manual step: POST /contracts/interfaces with contract ABI

#### Cause 2: Contract API Creation

- Contract API must be explicitly created for each contract
- This maps FFI to deployed contract address
- Manual step: POST /apis with contract address and FFI reference

#### Cause 3: Address Tracking

- Asset Manager only tracks explicitly registered addresses
- Treasury wallets and user wallets must be added to tracking
- Manual steps:
  - PATCH /addresses/{address} for contract
  - PATCH /addresses/{address} for each wallet

#### Cause 4: Display Names Not Auto-populated

- Assets appear with technical IDs, not human-readable names
- displayName and description fields require manual PATCH
- API quirk: Cannot change "name" field after creation (causes 404 error)

### 3.3 Wallet Manager Separation

Critical finding: Asset Manager and Wallet Manager are separate systems.

| System | Function | Auto-sync? |
|--------|----------|------------|
| Asset Manager | Event indexing, transfer history | Indexes from FFListener |
| Wallet Manager | Balance display, custody UI | NO - requires manual asset connection |

To display tokens in Wallet Manager:

1. POST /assets - Create asset definition
2. POST /wallets/{wallet}/connect/{asset} - Connect each wallet

### 3.4 API Issues Encountered

| Issue | Error Message | Resolution |
|-------|--------------|------------|
| Name with spaces | "must include only alphanumerics, dot, dash, underscore" | Use kebab-case names |
| Changing name field | 404 "Object does not exist" | Only update displayName, not name |
| Missing wallet connection | Token not visible in Custody | Manually connect wallet to asset |

---

## 4. Steps Required for Full Indexing

### Asset Manager Setup (for event visibility)

| Step | Endpoint | Purpose |
|------|----------|---------|
| 1 | POST /contracts/interfaces | Register FFI |
| 2 | POST /apis | Create Contract API |
| 3 | PATCH /assets/{id} | Set displayName |
| 4 | PATCH /addresses/{contract} | Track contract address |
| 5 | PATCH /addresses/{wallet} | Track wallet addresses |

### Wallet Manager Setup (for balance visibility)

| Step | Endpoint | Purpose |
|------|----------|---------|
| 1 | POST /assets | Create asset in Wallet Manager |
| 2 | POST /wallets/{id}/connect/{asset} | Connect each wallet |

---

## 5. Resolution

1. Documented all manual steps required for complete indexing
2. Identified API limitations (name field immutability)
3. Created working configuration for test token (STTN)
4. Verified indexing working after manual configuration

---

## 6. Recommendations

### Short-term

1. Create runbook documenting all required configuration steps
2. Use consistent naming convention (kebab-case) for assets

### Long-term

1. Request Kaleido feature: Auto-detect new contracts from known factories
2. Request Kaleido feature: Auto-connect wallets to new assets
3. Consider Terraform automation for repeatable setup

---

## 7. Test Evidence

After manual configuration, indexing works correctly.

**Asset Manager (GET /transfers):**

- Shows all MINT/TRANSFER/BURN events
- Correctly classifies transaction types
- Links to correct addresses

**Wallet Manager:**

| Wallet | Balance |
|--------|---------|
| test-wallet-1 | 6.70 STTN |
| test-wallet-2 | 0.10 STTN |

Balances update after each transaction.

---

## 8. Conclusion

Asset Manager indexing is NOT fully automated. Significant manual configuration is required:

- 5 steps for Asset Manager
- 2 steps per wallet for Wallet Manager

This explains why initial token deployment did not result in immediate visibility. The platform requires explicit configuration at multiple layers.

**Estimated setup time per new token:** 30-60 minutes (manual) or approximately 5 minutes (with Terraform automation)
