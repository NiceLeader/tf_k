# ERC20 Burnable Token - Instrukcja Wdrożenia

## Podsumowanie
Nowy kontrakt ERC20 z funkcją **burn** został wdrożony i przetestowany.

## Kluczowe dane

| Element | Wartość |
|---------|---------|
| **Adres kontraktu** | `0xa3ef4754971b31eb71b9289f804f21006e70dc7b` |
| **Interface ID** | `c34b740e-35e3-439b-a96e-b8099414d11b` |
| **API Name** | `simple-test-token-new` |
| **Token Name** | Simple Test Token New |
| **Token Symbol** | STTN |
| **Decimals** | 18 |
| **Owner/Signing Key** | `0xd045228c9a6d53b81cf15d15408af32ebad3b9cf` |

## Swagger API
```
https://account1.platform.ape1-c1.scb.kaleido.cloud/endpoint/dlt-da-01/sc-chain-casa-core/rest/api/v1/apis/simple-test-token-new/api
```

---

## Proces wdrożenia krok po kroku

### Krok 1: Zarejestruj interfejs kontraktu (FFI)

**Endpoint:** `POST /contracts/interfaces/generate`

**Body:** (plik `step1-register-interface.json`)
```json
{
  "name": "simple-test-token-new",
  "version": "1.0.0",
  "input": {
    "abi": [/* pełne ABI kontraktu ERC20Burnable */]
  }
}
```

**Następnie:** Skopiuj response i wyślij do `POST /contracts/interfaces`

**Wynik:** Interface ID

---

### Krok 2: Wdróż kontrakt

**Endpoint:** `POST /contracts/deploy?confirm=true`

**Body:** (plik `step2-deploy-contract.json`)
```json
{
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf",
  "contract": "0x608060405...",  // bytecode
  "definition": [{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"symbol","type":"string"}],"stateMutability":"nonpayable","type":"constructor"}],
  "input": ["Simple Test Token New", "STTN"]
}
```

**Wynik:** Adres kontraktu w `output.contractLocation.address`

---

### Krok 3: Utwórz API kontraktu

**Endpoint:** `POST /apis`

**Body:** (plik `step3-create-api.json`)
```json
{
  "interface": {
    "name": "simple-test-token-new",
    "version": "1.0.0"
  },
  "location": {
    "address": "0xa3ef4754971b31eb71b9289f804f21006e70dc7b"
  },
  "name": "simple-test-token-new"
}
```

**Wynik:** API URL do wywoływania funkcji kontraktu

---

### Krok 4: Zaktualizuj tfvars

Zaktualizuj pliki:
- `vars/dev.tfvars`
- `vars/example.tfvars`
- `digital_assets_standalone/vars/dev.tfvars`

```hcl
token_name                      = "Simple Test Token New"
token_symbol                    = "STTN"
existing_token_contract_address = "0xa3ef4754971b31eb71b9289f804f21006e70dc7b"
```

---

## Testowanie funkcji

### MINT
```json
POST /apis/simple-test-token-new/invoke/mint?confirm=true
{
  "input": {
    "to": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf",
    "amount": "1000000000000000000"
  },
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}
```

### TRANSFER
```json
POST /apis/simple-test-token-new/invoke/transfer?confirm=true
{
  "input": {
    "to": "0x...",
    "value": "100000000000000000"
  },
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}
```

### BURN
```json
POST /apis/simple-test-token-new/invoke/burn?confirm=true
{
  "input": {
    "value": "50000000000000000"
  },
  "key": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}
```

### Sprawdź balans
```json
POST /apis/simple-test-token-new/query/balanceOf
{
  "input": {
    "account": "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
  }
}
```

---

## Transakcje testowe

| Operacja | Transaction Hash | Status |
|----------|-----------------|--------|
| MINT | `0xc5c39f60d963d0c882c188a4faee3c64ed2e845cecd89d9271044285ad3a022f` | ✅ |
| TRANSFER | `0xc7b30ef0da1e2c90e8eb93125c42790300ec58765555cab5fcdd182cb3d0bffe` | ✅ |
| BURN | `0x72b0a1e7651feaca5d99c5dc33c05afecfc22280fd8ae9ae8be7cc0d7762ba2b` | ✅ |

---

## Pliki konfiguracyjne

- `step1-register-interface.json` - Body do rejestracji interfejsu
- `step2-deploy-contract.json` - Body do wdrożenia kontraktu
- `step3-create-api.json` - Body do utworzenia API
- `bytecode.txt` - Bytecode kontraktu ERC20Burnable

---

## Co dalej? (Prezentacja w Kaleido UI)

Aby token był widoczny w Kaleido Console/UI, potrzebne są dodatkowe kroki:

1. **TokenizationStack** - utworzenie Asset Managera który indeksuje token
2. **Wallet Creation** - utworzenie walletów w KeyManager
3. **FFListener** - nasłuchiwanie na eventy Transfer dla UI
4. **Terraform apply** - wdrożenie infrastruktury

Szczegóły w sekcji "Kaleido UI Integration" poniżej.
