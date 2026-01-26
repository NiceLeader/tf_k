# Investigation Report

## Blockchain Events Visibility

**Ticket:** 11889462

**Status:** Completed

**Date:** 2025-01-26

---

## 1. Summary

Investigation into inconsistency between blockchain transactions and their visibility in Kaleido platform. Events that exist on-chain were not consistently appearing in Kaleido Asset Manager UI.

---

## 2. Problem Statement

As a Kaleido developer, blockchain events (transfers, mints, burns) executed on-chain were not consistently visible in the Kaleido platform, causing misalignment between actual blockchain state and what Kaleido displays.

---

## 3. Investigation Findings

### 3.1 Event Flow Architecture

The blockchain events flow through multiple components:

| Step | Component | Function |
|------|-----------|----------|
| 1 | Blockchain (Besu EVM) | Source of events |
| 2 | EVMConnect | Event listener - captures events |
| 3 | FireFly Core | Event processing |
| 4 | FFListener | Indexing service |
| 5 | Asset Manager | UI/API visibility |
| 6 | Wallet Manager | Balance display |

### 3.2 Root Causes Identified

#### Issue 1: FFListener Configuration

- FFListener must be properly configured to listen to specific contract events
- New contracts require explicit FFI (FireFly Interface) registration
- Impact: Events from unregistered contracts are not indexed

#### Issue 2: Asset Manager vs Wallet Manager Separation

- Asset Manager indexes events but Wallet Manager displays balances separately
- These are two independent systems that require separate configuration
- Impact: Events visible in Asset Manager may not reflect in Wallet Manager balances

#### Issue 3: Event Visibility Endpoints

Multiple endpoints exist for viewing events:

| Endpoint | Purpose |
|----------|---------|
| GET /blockchainevents | Raw blockchain events |
| GET /transfers | Processed transfer events with type classification |
| GET /balances | Aggregated balance view |

Impact: Users may check wrong endpoint and assume events are missing.

### 3.3 Verified Working Endpoints

| Endpoint | Purpose | Status |
|----------|---------|--------|
| GET /blockchainevents | Raw events from chain | OK |
| GET /transfers | Indexed transfers with mint/burn/transfer types | OK |
| GET /balances | Current token balances | OK |
| GET /listeners | Active event listeners | OK |

---

## 4. Resolution

1. Confirmed event visibility through GET /blockchainevents endpoint
2. Verified FFListener is actively indexing Transfer events
3. Documented correct endpoints for different visibility needs
4. Tested end-to-end flow: MINT, TRANSFER, BURN all visible in Asset Manager

---

## 5. Recommendations

1. Always verify FFListener configuration when deploying new contracts
2. Use GET /transfers for human-readable event history (includes type classification)
3. Use GET /blockchainevents for raw event debugging
4. Document event flow architecture for team reference

---

## 6. Test Evidence

Transactions verified visible in Kaleido:

| Operation | Transaction Hash | Status |
|-----------|------------------|--------|
| MINT | 0xc5c39f60d963d0c882c188a4faee3c64ed2e845cecd89d9271044285ad3a022f | OK |
| TRANSFER | 0xc7b30ef0da1e2c90e8eb93125c42790300ec58765555cab5fcdd182cb3d0bffe | OK |
| BURN | 0x72b0a1e7651feaca5d99c5dc33c05afecfc22280fd8ae9ae8be7cc0d7762ba2b | OK |

All events correctly classified by type (mint/transfer/burn) in Asset Manager.

---

## 7. Conclusion

Blockchain events ARE visible in Kaleido when:

1. FFListener is properly configured for the contract
2. Correct endpoint is used for the desired view
3. Contract has registered FFI (FireFly Interface)

The perceived "invisibility" was due to checking wrong endpoints or missing configuration steps, not a platform defect.
