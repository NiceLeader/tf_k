# Investigation Report: EVMConnect Not Publishing Blockchain Events

**Ticket:** 11891053
**Title:** Investigation: evmconnect not publishing blockchain events
**Status:** Completed
**Date:** 2025-01-26

---

## Summary

Investigation into why EVMConnect appears to not publish blockchain events consistently. Found that EVMConnect itself functions correctly, but visibility issues stem from missing configuration in downstream components.

---

## Problem Statement

As a Kaleido developer, blockchain events executed on-chain were not appearing in Kaleido. Initial hypothesis was that EVMConnect was not publishing events properly.

---

## Investigation Findings

### 1. EVMConnect Architecture

EVMConnect is the bridge between blockchain and FireFly:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Kaleido Platform                          │
│                                                                   │
│   ┌──────────┐    ┌─────────────┐    ┌──────────────────────┐   │
│   │  Besu    │───▶│ EVMConnect  │───▶│   FireFly Core       │   │
│   │  (EVM)   │    │ (connector) │    │   (event processor)  │   │
│   └──────────┘    └─────────────┘    └──────────────────────┘   │
│        │                                        │                 │
│        │              Event Stream              │                 │
│        │         ┌─────────────────┐           │                 │
│        └────────▶│   FFListener    │◀──────────┘                 │
│                  │   (subscriber)  │                             │
│                  └─────────────────┘                             │
│                           │                                       │
│                           ▼                                       │
│                  ┌─────────────────┐                             │
│                  │  Asset Manager  │                             │
│                  │  (indexer/UI)   │                             │
│                  └─────────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Root Cause Analysis

**Initial hypothesis:** EVMConnect not publishing events
**Actual root cause:** Events published but not subscribed/decoded

#### 2.1 EVMConnect Status: WORKING
- **Finding:** EVMConnect publishes ALL blockchain events to FireFly
- **Evidence:** `GET /blockchainevents` shows raw events from chain
- **Conclusion:** EVMConnect is NOT the problem

#### 2.2 Event Subscription: REQUIRES CONFIGURATION
- **Finding:** FFListener must subscribe to specific event types
- **Issue:** Without subscription, events are published but ignored
- **Solution:** Create FFI and event listener for contract

#### 2.3 Event Decoding: REQUIRES FFI
- **Finding:** Raw events are hex-encoded and not human-readable
- **Issue:** Without FFI (ABI), events cannot be decoded
- **Solution:** Register contract ABI as FireFly Interface

### 3. Event Publishing Flow

| Step | Component | Status | Notes |
|------|-----------|--------|-------|
| 1 | Blockchain emits event | ✅ Working | Event exists on-chain |
| 2 | EVMConnect captures event | ✅ Working | Events in /blockchainevents |
| 3 | FireFly processes event | ✅ Working | Core functionality OK |
| 4 | FFListener subscribes | ⚠️ Requires config | Needs FFI registration |
| 5 | Asset Manager indexes | ⚠️ Requires config | Needs address tracking |
| 6 | Wallet Manager displays | ⚠️ Requires config | Needs asset connection |

### 4. Verification Tests

#### Test 1: Raw Events Available
```
GET /blockchainevents
Result: ✅ All blockchain events visible (hex-encoded)
```

#### Test 2: Decoded Events (after FFI setup)
```
GET /transfers
Result: ✅ Events decoded with type classification (mint/transfer/burn)
```

#### Test 3: Transaction Execution
```
POST /invoke/mint → Transaction hash returned → Event visible in Asset Manager
POST /invoke/transfer → Transaction hash returned → Event visible in Asset Manager
POST /invoke/burn → Transaction hash returned → Event visible in Asset Manager
```

---

## Root Cause Summary

| Suspected Issue | Actual Issue | Resolution |
|-----------------|--------------|------------|
| EVMConnect not publishing | FFListener not subscribed | Register FFI + create listener |
| Events lost in transit | Events not decoded | Provide contract ABI |
| Platform defect | Missing configuration | Manual setup required |

---

## Resolution

1. **Confirmed EVMConnect is working** - raw events available in /blockchainevents
2. **Identified actual issue** - missing FFI registration and listener subscription
3. **Completed configuration** - FFI, Contract API, FFListener all configured
4. **Verified end-to-end** - MINT/TRANSFER/BURN all publishing and visible

---

## Recommendations

### Immediate:
1. Always check `GET /blockchainevents` first to verify events reach Kaleido
2. If raw events exist but decoded events don't, check FFI configuration
3. Use provided transaction hashes for troubleshooting

### Process Improvement:
1. Create checklist for new contract deployment
2. Include FFI registration as mandatory step
3. Document event subscription requirements

### Technical Debt:
1. Consider auto-FFI generation from verified contract source
2. Request Kaleido feature: Alert when events published but no subscribers

---

## Test Evidence

Verified transactions publishing correctly:

| Operation | Tx Hash | On-chain | EVMConnect | Asset Manager |
|-----------|---------|----------|------------|---------------|
| MINT | `0xc5c39f60...` | ✅ | ✅ | ✅ |
| TRANSFER | `0xc7b30ef0...` | ✅ | ✅ | ✅ |
| BURN | `0x72b0a1e7...` | ✅ | ✅ | ✅ |

---

## Conclusion

EVMConnect IS publishing blockchain events correctly. The perceived "not publishing" issue was caused by:

1. **Missing FFI registration** - events not decoded
2. **Missing listener subscription** - events not indexed
3. **Missing Asset Manager configuration** - events not displayed

After proper configuration, all events flow correctly from blockchain to UI.

**Key learning:** "Not publishing" symptoms can indicate subscription/decoding issues, not actual publishing failures. Always verify raw events first.
