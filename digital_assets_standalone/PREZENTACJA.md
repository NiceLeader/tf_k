# Digital Assets - Notatki do Prezentacji

## Co zrobiliśmy?

Stworzyliśmy **moduł Terraform** do automatycznego deploymentu Digital Assets na platformie Kaleido.

---

## Problem biznesowy

Potrzebujemy infrastruktury do:
- Śledzenia tokenów (ERC20)
- Zarządzania portfelami
- Integracji z middleware (FireFly)

**Rozwiązanie:** Skrypty Terraform które tworzą całą infrastrukturę automatycznie.

---

## Co moduł tworzy?

### 1. TokenizationStack (do tokenów)
- **AssetManager** - serwis do zarządzania aktywami cyfrowymi
- **ERC20 Indexer** - automatycznie śledzi transfery tokenów
- **FireFly Listener** - nasłuchuje na eventy z blockchain

### 2. CustodyStack (do portfeli)
- **WalletManager** - serwis do zarządzania portfelami

### 3. Wallet & Key (do podpisywania)
- **HD Wallet** - portfel hierarchiczny
- **Signing Key** - klucz do podpisywania transakcji

---

## Co Terraform tworzy vs co jest automatyczne?

| Element | Terraform | Automatycznie | Ręcznie (UI) |
|---------|-----------|---------------|--------------|
| Stacks (Tokenization, Custody) | ✅ | | |
| Services (AssetManager, WalletManager) | ✅ | | |
| Wallet & Key (w KeyManager) | ✅ | | |
| ERC20 Indexer Task | ✅ | | |
| FireFly Listener | ✅ | | |
| **Assety** | ❌ | ✅ (przez Indexer) | ✅ |
| **Adresy** | ❌ | ✅ (przez Indexer) | ✅ |
| **Transfery** | ❌ | ✅ (przez Indexer) | |

**Ważne:** Terraform tworzy **infrastrukturę**. Dane (assety, adresy, transfery) pojawiają się automatycznie gdy ERC20 Indexer wykryje transakcje na blockchainie.

---

## Jak to działa?

```
KeyManager (FireFly Signer)
         │
         ├── Wallet + Signing Key
         │
         ▼
    ┌─────────────────────────────────────┐
    │                                     │
    ▼                                     ▼
TokenizationStack                   CustodyStack
(AssetManager)                      (WalletManager)
    │
    ▼
ERC20 Indexer ──► FireFly ──► Blockchain Events
                                    │
                                    ▼
                          Automatyczne tworzenie:
                          - Assetów
                          - Adresów
                          - Transferów
```

---

## Konfigurowalność

Wszystko można włączyć/wyłączyć przez zmienne:

```hcl
enable_tokenization_stack = true/false
enable_custody_stack      = true/false
enable_wallet_creation    = true/false
enable_erc20_indexer      = true/false
```

---

## Integracja z FireFly

- ERC20 Indexer nasłuchuje na eventy `Transfer` przez FireFly
- Automatycznie rejestruje adresy gdy wykryje transakcje
- Tworzy historię transferów tokenów

---

## Struktura projektu

```
digital_assets_standalone/
├── module/           # Moduł (zasoby Terraform)
├── vars/             # Konfiguracje środowisk
│   ├── example.tfvars    # Template
│   └── dev.tfvars        # DEV config
└── README.md         # Dokumentacja
```

---

## Użycie

```bash
# 1. Inicjalizacja
terraform init

# 2. Sprawdzenie planu
terraform plan -var-file="vars/dev.tfvars"

# 3. Deployment
terraform apply -var-file="vars/dev.tfvars"
```

---

## Wymagania z ticketu - DONE ✅

| Wymaganie | Status |
|-----------|--------|
| Digital asset service dla token currency | ✅ |
| Skrypty konfigurowalne | ✅ |
| Skrypty zlinkowane z middleware (FireFly) | ✅ |

---

## Pytania które mogą paść

**Q: Dlaczego nie widzę żadnych assetów?**
A: Assety pojawiają się automatycznie gdy ERC20 Indexer wykryje transakcje tokenów na blockchainie. Teraz mamy gotową infrastrukturę - gdy będą transakcje, assety się pojawią. Można też dodać assety ręcznie przez UI.

**Q: Dlaczego dwa stacki (Tokenization i Custody)?**
A: Separacja odpowiedzialności - TokenizationStack do aktywów/tokenów, CustodyStack do portfeli. Oba mogą działać niezależnie.

**Q: Gdzie są widoczne portfele?**
A: Wallet i Key są w KeyManager (FireFly Signer). Adresy w WalletManager/AssetManager pojawią się automatycznie gdy ERC20 Indexer wykryje transakcje.

**Q: Dlaczego assety nie są tworzone przez Terraform?**
A: Provider Kaleido nie ma zasobu do tworzenia assetów. Assety to dane operacyjne - tworzone automatycznie przez Indexer lub ręcznie przez UI/API. Terraform tworzy infrastrukturę (stacki, serwisy, indexery).

**Q: Czy można dodać więcej środowisk?**
A: Tak, wystarczy skopiować `vars/dev.tfvars` do np. `vars/prod.tfvars` i zmienić wartości.

---

## Demo

1. Pokaż strukturę plików (`digital_assets_standalone/`)
2. Pokaż `vars/example.tfvars` - jakie zmienne można ustawić
3. Pokaż Kaleido Console:
   - TokenizationStack z AssetManager
   - CustodyStack z WalletManager
   - KeyManager z Wallet i Key
4. Wyjaśnij że assety pojawią się gdy będą transakcje
