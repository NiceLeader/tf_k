# ERC20 Token Demo - Instrukcja dla Mohita

## Podsumowanie
Demonstracja funkcjonalności tokena ERC20 z funkcją **BURN** na platformie Kaleido.

---

## Kluczowe dane

| Element | Wartość |
|---------|---------|
| **Token Name** | Simple Test Token New |
| **Symbol** | STTN |
| **Decimals** | 18 |
| **Contract Address** | `0xa3ef4754971b31eb71b9289f804f21006e70dc7b` |
| **Treasury Wallet** | `0xd045228c9a6d53b81cf15d15408af32ebad3b9cf` |

---

## Dostęp do Swagger UI

### Asset Manager (do podglądu transfers/balances)
```
https://account1.platform.ape1-c1.scb.kaleido.cloud/endpoint/dlt-da-01/asset-manager/rest/api/v1
```

### Token API (do wykonywania operacji mint/transfer/burn)
```
https://account1.platform.ape1-c1.scb.kaleido.cloud/endpoint/dlt-da-01/sc-chain-casa-core/rest/api/v1/apis/simple-test-token-new/api
```

---

## DEMO: Krok po kroku

### 1. Pokaż aktualny balans

**Swagger:** Asset Manager
**Endpoint:** `GET /balances`

**Wynik:** Pokaże saldo tokena STTN dla Treasury Wallet

---

### 2. Pokaż historię transferów

**Swagger:** Asset Manager
**Endpoint:** `GET /transfers`

**Wynik:** Lista wszystkich operacji z typami:
- `mint` - utworzenie tokenów (from: 0x0000...)
- `transfer` - przelew między adresami
- `burn` - spalenie tokenów (to: 0x0000...)

---

### 3. Wykonaj MINT (opcjonalnie - live demo)

**Swagger:** Token API (`simple-test-token-new`)
**Endpoint:** `POST /invoke/mint?confirm=true`

**Body:**
```json
{
  "input": {
    "to": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf",
    "amount": "1000000000000000000"
  },
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}
```

**Wynik:** Utworzenie 1 STTN tokena

---

### 4. Wykonaj TRANSFER (opcjonalnie - live demo)

**Swagger:** Token API (`simple-test-token-new`)
**Endpoint:** `POST /invoke/transfer?confirm=true`

**Body:**
```json
{
  "input": {
    "to": "0x94d2ecc5ea0efa1a8cab7ecffaa95b4c30dab361",
    "value": "100000000000000000"
  },
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}
```

**Wynik:** Przelanie 0.1 STTN na inny adres

---

### 5. Wykonaj BURN (kluczowa funkcjonalność!)

**Swagger:** Token API (`simple-test-token-new`)
**Endpoint:** `POST /invoke/burn?confirm=true`

**Body:**
```json
{
  "input": {
    "value": "50000000000000000"
  },
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}
```

**Wynik:** Spalenie 0.05 STTN (nieodwracalne usunięcie z obiegu)

---

### 6. Zweryfikuj operacje

**Swagger:** Asset Manager
**Endpoint:** `GET /transfers`

**Wynik:** Nowe operacje widoczne w historii z odpowiednimi typami

---

## Przetestowane transakcje

| Operacja | Transaction Hash | Status |
|----------|-----------------|--------|
| MINT | `0xc5c39f60d963d0c882c188a4faee3c64ed2e845cecd89d9271044285ad3a022f` | ✅ |
| TRANSFER | `0xc7b30ef0da1e2c90e8eb93125c42790300ec58765555cab5fcdd182cb3d0bffe` | ✅ |
| BURN | `0x72b0a1e7651feaca5d99c5dc33c05afecfc22280fd8ae9ae8be7cc0d7762ba2b` | ✅ |

---

## Architektura

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Token API     │────▶│   Blockchain    │────▶│  Asset Manager  │
│ (FireFly Core)  │     │   (Besu EVM)    │     │  (FFListener)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
   mint/burn/transfer     Smart Contract          Indexing &
   transactions           execution               tracking
```

---

## Uwagi

- **BURN** - nowy kontrakt ERC20Burnable (stary kontrakt nie miał tej funkcji)
- **Wszystkie operacje** są automatycznie indeksowane przez Asset Manager
- **Transakcje** są nieodwracalne i zapisane na blockchain

---

## Kontakt

W razie pytań: sprawdź `DEPLOYMENT_INSTRUCTIONS.md` w tym samym folderze.
