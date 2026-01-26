# Investigation Report: Blockchain Events Visibility

**Ticket:** 11889462
**Title:** Investigation: blockchain events Visibility
**Status:** Completed
**Date:** 2025-01-26

---

## Summary

Investigation into inconsistency between blockchain transactions and their visibility in Kaleido platform. Events that exist on-chain were not consistently appearing in Kaleido Asset Manager UI.

---

## Problem Statement

As a Kaleido developer, blockchain events (transfers, mints, burns) executed on-chain were not consistently visible in the Kaleido platform, causing misalignment between actual blockchain state and what Kaleido displays.

---

## Investigation Findings

### 1. Event Flow Architecture

The blockchain events flow through multiple components:

```
Blockchain (Besu EVM)
       ↓
   EVMConnect (event listener)
       ↓
   FireFly Core (event processing)
       ↓
   FFListener (indexing service)
       ↓
   Asset Manager (UI/API visibility)
       ↓
   Wallet Manager (balance display)
```

### 2. Root Causes Identified

#### 2.1 FFListener Configuration
- **Issue:** FFListener must be properly configured to listen to specific contract events
- **Finding:** New contracts require explicit FFI (FireFly Interface) registration
- **Impact:** Events from unregistered contracts are not indexed

#### 2.2 Asset Manager vs Wallet Manager Separation
- **Issue:** Asset Manager indexes events but Wallet Manager displays balances separately
- **Finding:** These are two independent systems that require separate configuration
- **Impact:** Events visible in Asset Manager may not reflect in Wallet Manager balances

#### 2.3 Event Visibility Endpoints
- **Finding:** Multiple endpoints exist for viewing events:
  - `GET /blockchainevents` - raw blockchain events
  - `GET /transfers` - processed transfer events with type classification
  - `GET /balances` - aggregated balance view
- **Impact:** Users may check wrong endpoint and assume events are missing

### 3. Verified Working Endpoints

| Endpoint | Purpose | Status |
|----------|---------|--------|
| `GET /blockchainevents` | Raw events from chain | Working |
| `GET /transfers` | Indexed transfers with mint/burn/transfer types | Working |
| `GET /balances` | Current token balances | Working |
| `GET /listeners` | Active event listeners | Working |

---

## Resolution

1. **Confirmed event visibility** through `GET /blockchainevents` endpoint
2. **Verified FFListener** is actively indexing Transfer events
3. **Documented correct endpoints** for different visibility needs
4. **Tested end-to-end flow**: MINT → TRANSFER → BURN all visible in Asset Manager

---

## Recommendations

1. Always verify FFListener configuration when deploying new contracts
2. Use `GET /transfers` for human-readable event history (includes type classification)
3. Use `GET /blockchainevents` for raw event debugging
4. Document event flow architecture for team reference

---

## Test Evidence

Transactions verified visible in Kaleido:
- MINT: `0xc5c39f60d963d0c882c188a4faee3c64ed2e845cecd89d9271044285ad3a022f`
- TRANSFER: `0xc7b30ef0da1e2c90e8eb93125c42790300ec58765555cab5fcdd182cb3d0bffe`
- BURN: `0x72b0a1e7651feaca5d99c5dc33c05afecfc22280fd8ae9ae8be7cc0d7762ba2b`

All events correctly classified by type (mint/transfer/burn) in Asset Manager.

---

## Conclusion

Blockchain events ARE visible in Kaleido when:
1. FFListener is properly configured for the contract
2. Correct endpoint is used for the desired view
3. Contract has registered FFI (FireFly Interface)

The perceived "invisibility" was due to checking wrong endpoints or missing configuration steps, not a platform defect.
