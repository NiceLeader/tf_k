# Plan Automatyzacji Terraform - Digital Assets (STTN Token)

## Wymaganie
> "We want Terraform scripts. Scripts should be configurable."

---

## Status obecny

### ✅ CO MAMY (natywne Terraform resources):

| Resource | Typ | Lokalizacja |
|----------|-----|-------------|
| `kaleido_platform_stack` | TokenizationStack, CustodyStack | `digital_assets_standalone/` |
| `kaleido_platform_runtime` | AssetManager, WalletManager | `digital_assets_standalone/` |
| `kaleido_platform_service` | Services | `digital_assets_standalone/` |
| `kaleido_platform_kms_wallet` | HD Wallets | `digital_assets_standalone/` |
| `kaleido_platform_kms_key` | Signing Keys | `digital_assets_standalone/` |
| `kaleido_platform_ams_task` | ERC20 Indexer task | `digital_assets_standalone/` |
| `kaleido_platform_ams_fflistener` | FireFly Listener | `digital_assets_standalone/` |

### ❌ CZEGO BRAKUJE (brak natywnych resources w providerze):

| Element | API Endpoint | Metoda | Rozwiązanie |
|---------|-------------|--------|-------------|
| Deploy smart kontraktu | `/contracts/deploy` | POST | `null_resource` + curl |
| Rejestracja FFI interface | `/contracts/interfaces` | POST | `null_resource` + curl |
| Tworzenie Contract API | `/apis` | POST | `null_resource` + curl |
| Asset w Wallet Manager | `/wallet-manager/assets` | POST | `null_resource` + curl |
| Połączenie Wallet↔Asset | `/wallets/{id}/connect/{asset}` | POST | `null_resource` + curl |
| Address displayName | `/asset-manager/addresses/{addr}` | PATCH | `null_resource` + curl |
| Asset displayName | `/asset-manager/assets/{id}` | PATCH | `null_resource` + curl |

> **UWAGA:** Resource `kaleido_platform_ams_address` nie jest dostępny w providerze v1.1.0

---

## Plan implementacji Terraform

> **Podejście:** Użycie `null_resource` + `local-exec` + curl dla operacji niedostępnych w providerze.
> Wyniki zapisywane do plików JSON, parsowane przez `data.local_file`.

---

### Moduł 1: Contract Deployment
**Plik:** `modules/digital_assets/contract_deploy.tf`

```hcl
variable "contract_config" {
  type = object({
    name        = string
    symbol      = string
    bytecode    = string
    signing_key = string
  })
  default = {
    name        = "Simple Test Token New"
    symbol      = "STTN"
    bytecode    = ""  # lub file("./contracts/ERC20Burnable.bin")
    signing_key = ""
  }
}

# Deploy contract via curl
resource "null_resource" "deploy_contract" {
  triggers = {
    bytecode = var.contract_config.bytecode
    name     = var.contract_config.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X POST \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{
          "key": "${var.contract_config.signing_key}",
          "contract": "${var.contract_config.bytecode}",
          "definition": [{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"symbol","type":"string"}],"stateMutability":"nonpayable","type":"constructor"}],
          "input": ["${var.contract_config.name}", "${var.contract_config.symbol}"]
        }' \
        "${var.firefly_url}/contracts/deploy?confirm=true" \
        > ${path.module}/outputs/contract_deploy_result.json
    EOT
  }
}

# Read deployed contract address from result
data "local_file" "contract_deploy_result" {
  depends_on = [null_resource.deploy_contract]
  filename   = "${path.module}/outputs/contract_deploy_result.json"
}

locals {
  contract_address = try(
    jsondecode(data.local_file.contract_deploy_result.content).output.contractLocation.address,
    ""
  )
}

output "deployed_contract_address" {
  value = local.contract_address
}
```

**Konfigurowalność:**
- `name` - nazwa tokena
- `symbol` - symbol (np. STTN)
- `bytecode` - bytecode kontraktu (hex string)
- `signing_key` - adres klucza do podpisania transakcji

---

### Moduł 2: FireFly Interface (FFI)
**Plik:** `modules/digital_assets/ffi_interface.tf`

```hcl
variable "interface_config" {
  type = object({
    name    = string
    version = string
    abi     = string  # JSON string of ABI
  })
}

# Step 1: Generate interface from ABI
resource "null_resource" "generate_interface" {
  depends_on = [null_resource.deploy_contract]

  triggers = {
    abi = var.interface_config.abi
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X POST \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{
          "name": "${var.interface_config.name}",
          "version": "${var.interface_config.version}",
          "input": {
            "abi": ${var.interface_config.abi}
          }
        }' \
        "${var.firefly_url}/contracts/interfaces/generate" \
        > ${path.module}/outputs/interface_generated.json
    EOT
  }
}

# Step 2: Register interface
resource "null_resource" "register_interface" {
  depends_on = [null_resource.generate_interface]

  provisioner "local-exec" {
    command = <<-EOT
      GENERATED=$(cat ${path.module}/outputs/interface_generated.json)
      curl -s -X POST \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d "$GENERATED" \
        "${var.firefly_url}/contracts/interfaces" \
        > ${path.module}/outputs/interface_registered.json
    EOT
  }
}

data "local_file" "interface_result" {
  depends_on = [null_resource.register_interface]
  filename   = "${path.module}/outputs/interface_registered.json"
}

locals {
  interface_id = try(jsondecode(data.local_file.interface_result.content).id, "")
}
```

### Moduł 2b: Contract API
**Plik:** `modules/digital_assets/contract_api.tf`

```hcl
variable "api_config" {
  type = object({
    name              = string
    interface_name    = string
    interface_version = string
  })
}

resource "null_resource" "create_api" {
  depends_on = [null_resource.register_interface]

  triggers = {
    contract_address = local.contract_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X POST \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{
          "name": "${var.api_config.name}",
          "interface": {
            "name": "${var.api_config.interface_name}",
            "version": "${var.api_config.interface_version}"
          },
          "location": {
            "address": "${local.contract_address}"
          }
        }' \
        "${var.firefly_url}/apis" \
        > ${path.module}/outputs/api_created.json
    EOT
  }
}
```

**Konfigurowalność:**
- `interface_name` - nazwa interface (np. "simple-test-token-new")
- `interface_version` - wersja (np. "1.0.0")
- `abi` - pełne ABI jako JSON string

---

### Moduł 3: FFListener (mamy - natywny resource)
**Plik:** `modules/digital_assets/fflistener.tf`

> ✅ Ten moduł już istnieje jako `kaleido_platform_ams_fflistener` - tylko rozszerzyć parametryzację.

```hcl
variable "listener_config" {
  type = object({
    contract_address = string
    from_block       = string
  })
  default = {
    contract_address = ""  # użyj local.contract_address
    from_block       = "0"
  }
}

# Już mamy w digital_assets_standalone/module/main.tf
resource "kaleido_platform_ams_fflistener" "erc20_indexer" {
  # ... existing code ...
  config_json = jsonencode({
    # Update: użyj local.contract_address z contract_deploy
    locations = [{ address = local.contract_address }]
    # ... rest of config ...
  })
}
```

**Konfigurowalność:**
- `contract_address` - automatycznie z `local.contract_address`
- `from_block` - od którego bloku słuchać (domyślnie "0")

---

### Moduł 4: Wallet Manager Asset
**Plik:** `modules/digital_assets/wallet_asset.tf`

```hcl
variable "wallet_asset_config" {
  type = object({
    name        = string
    symbol      = string
    decimals    = number
    description = string
  })
  default = {
    name        = "simple-test-token-new"
    symbol      = "STTN"
    decimals    = 18
    description = "ERC20 token with burn function"
  }
}

resource "null_resource" "create_wallet_asset" {
  depends_on = [null_resource.create_api]

  triggers = {
    contract_address = local.contract_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X POST \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{
          "name": "${var.wallet_asset_config.name}",
          "symbol": "${var.wallet_asset_config.symbol}",
          "protocolId": "${local.contract_address}",
          "accountIdentifierType": "eth_address",
          "description": "${var.wallet_asset_config.description}",
          "config": {
            "decimals": ${var.wallet_asset_config.decimals},
            "transfers": {
              "backend": "asset-manager",
              "backendId": "${local.contract_address}/pool",
              "backendType": "pool"
            }
          }
        }' \
        "${var.wallet_manager_url}/assets" \
        > ${path.module}/outputs/wallet_asset_created.json
    EOT
  }
}
```

**Konfigurowalność:**
- `name` - nazwa assetu w Wallet Manager
- `symbol` - symbol tokena
- `decimals` - miejsca po przecinku (18)
- `description` - opis assetu
- `protocol_id` - automatycznie z `local.contract_address`

---

### Moduł 5: Wallet Connections
**Plik:** `modules/digital_assets/wallet_connections.tf`

```hcl
variable "wallet_connections" {
  type = list(object({
    wallet_name = string
    asset_name  = string
  }))
  default = [
    { wallet_name = "test-wallet-1", asset_name = "simple-test-token-new" },
    { wallet_name = "test-wallet-2", asset_name = "simple-test-token-new" }
  ]
}

resource "null_resource" "connect_wallet_asset" {
  depends_on = [null_resource.create_wallet_asset]

  for_each = { for idx, conn in var.wallet_connections : "${conn.wallet_name}-${conn.asset_name}" => conn }

  triggers = {
    wallet = each.value.wallet_name
    asset  = each.value.asset_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X POST \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{}' \
        "${var.wallet_manager_url}/wallets/${each.value.wallet_name}/connect/${each.value.asset_name}" \
        > ${path.module}/outputs/wallet_connection_${each.key}.json
    EOT
  }
}
```

**Konfigurowalność:**
- `wallet_connections` - lista par wallet↔asset do połączenia
- Można dodawać dowolną liczbę walletów

---

### Moduł 6: Display Names (Asset Manager)
**Plik:** `modules/digital_assets/display_names.tf`

```hcl
variable "address_display_names" {
  type = map(string)
  default = {}
  description = "Map of address -> displayName"
}

variable "asset_display_config" {
  type = object({
    display_name = string
    description  = string
  })
  default = {
    display_name = "STTN - Simple Test Token New"
    description  = "ERC20 token with burn function"
  }
}

# Update address display names
resource "null_resource" "address_display_names" {
  depends_on = [null_resource.connect_wallet_asset]

  for_each = var.address_display_names

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X PATCH \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{"displayName": "${each.value}"}' \
        "${var.asset_manager_url}/addresses/${each.key}"
    EOT
  }
}

# Update asset display name (dynamically get asset ID)
resource "null_resource" "asset_display_name" {
  depends_on = [null_resource.address_display_names]

  provisioner "local-exec" {
    command = <<-EOT
      # Get asset ID for this contract
      ASSET_ID=$(curl -s \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        "${var.asset_manager_url}/assets" | \
        jq -r '.items[] | select(.name | contains("${local.contract_address}")) | .id')

      # Update display name
      curl -s -X PATCH \
        -u "${var.kaleido_api_key}:${var.kaleido_api_secret}" \
        -H "Content-Type: application/json" \
        -d '{"displayName": "${var.asset_display_config.display_name}", "description": "${var.asset_display_config.description}"}' \
        "${var.asset_manager_url}/assets/$ASSET_ID"
    EOT
  }
}
```

**Konfigurowalność:**
- `address_display_names` - mapa adres → nazwa wyświetlana
- `asset_display_config` - nazwa i opis assetu w Asset Manager

---

## Przykład użycia (końcowy tfvars)

```hcl
# vars/production.tfvars

# ===== CONTRACT DEPLOYMENT =====
contract_config = {
  name        = "Production Token"
  symbol      = "PROD"
  bytecode    = file("./contracts/ERC20Burnable.bin")
  signing_key = "0xd045228c9a6d53b81cf15d15408af32ebad3b9cf"
}

# ===== FFI INTERFACE =====
interface_config = {
  name    = "production-token"
  version = "1.0.0"
  abi     = file("./contracts/ERC20Burnable.abi.json")
}

# ===== CONTRACT API =====
api_config = {
  name              = "production-token"
  interface_name    = "production-token"
  interface_version = "1.0.0"
}

# ===== WALLET MANAGER ASSET =====
wallet_asset_config = {
  name        = "production-token"
  symbol      = "PROD"
  decimals    = 18
  description = "Production ERC20 token with burn function"
}

# ===== WALLET CONNECTIONS =====
wallet_connections = [
  { wallet_name = "treasury-wallet", asset_name = "production-token" },
  { wallet_name = "operations-wallet", asset_name = "production-token" },
  { wallet_name = "reserve-wallet", asset_name = "production-token" }
]

# ===== DISPLAY NAMES =====
address_display_names = {
  # contract address will be added after deploy
  # "0x..." = "PROD Token Contract"
}

asset_display_config = {
  display_name = "PROD - Production Token"
  description  = "Production ERC20 token with burn function"
}
```

---

## Wymagane zmienne (variables.tf)

```hcl
# API Credentials
variable "kaleido_api_key" {
  type        = string
  sensitive   = true
  description = "Kaleido API Key"
}

variable "kaleido_api_secret" {
  type        = string
  sensitive   = true
  description = "Kaleido API Secret"
}

# Service URLs
variable "firefly_url" {
  type        = string
  description = "FireFly API URL (e.g., https://...kaleido.cloud/.../rest/api/v1)"
}

variable "asset_manager_url" {
  type        = string
  description = "Asset Manager API URL"
}

variable "wallet_manager_url" {
  type        = string
  description = "Wallet Manager API URL"
}
```

---

## Estymacja czasu

| Moduł | Czas | Priorytet |
|-------|------|-----------|
| Contract Deployment | 2-3h | Wysoki |
| FFI Interface + API | 2-3h | Wysoki |
| FFListener (rozszerzenie) | 1h | Średni |
| Wallet Manager Asset | 2h | Wysoki |
| Wallet Connections | 1-2h | Średni |
| Display Names | 1h | Niski |
| Testy + dokumentacja | 2-3h | Wysoki |
| **RAZEM** | **~12-16h** | |

---

## Zależności

```
Contract Deploy
      ↓
FFI Interface
      ↓
Contract API
      ↓
FFListener ←──────────────┐
      ↓                   │
Wallet Manager Asset      │
      ↓                   │
Wallet Connections        │
      ↓                   │
Display Names ────────────┘
```

---

## Pliki do utworzenia

```
modules/digital_assets/
├── main.tf               # EXISTING - stacks, services (natywne)
├── contract_deploy.tf    # NEW - deploy kontraktu (curl)
├── ffi_interface.tf      # NEW - interface registration (curl)
├── contract_api.tf       # NEW - API creation (curl)
├── wallet_asset.tf       # NEW - asset w Wallet Manager (curl)
├── wallet_connections.tf # NEW - połączenia wallet↔asset (curl)
├── display_names.tf      # NEW - nazwy wyświetlane (curl)
├── variables.tf          # EXTEND - nowe zmienne
├── outputs.tf            # EXTEND - nowe outputy
├── versions.tf           # EXISTING
└── outputs/              # NEW - directory for curl results
    ├── .gitkeep
    ├── contract_deploy_result.json
    ├── interface_generated.json
    ├── interface_registered.json
    ├── api_created.json
    ├── wallet_asset_created.json
    └── wallet_connection_*.json

contracts/                # NEW - contract files
├── ERC20Burnable.bin     # Bytecode
└── ERC20Burnable.abi.json # ABI
```

---

## Uwagi implementacyjne

1. **Idempotentność**
   - `null_resource` z curl nie jest idempotentny
   - Dodać sprawdzanie czy resource już istnieje przed utworzeniem
   - Użyć `triggers` do kontroli kiedy re-run

2. **Error Handling**
   - Dodać sprawdzanie HTTP status codes
   - Logować błędy do osobnych plików
   - Rozważyć użycie `|| true` dla opcjonalnych operacji

3. **State Management**
   - `local.contract_address` musi być dostępny dla innych resources
   - Użyć `depends_on` dla właściwej kolejności
   - Outputs zapisywane do plików JSON

4. **Secrets & Security**
   - Credentials przez zmienne środowiskowe lub Vault
   - NIE commitować `outputs/` directory
   - Dodać `outputs/` do `.gitignore`

5. **Wymagania systemowe**
   - `curl` musi być dostępny
   - `jq` dla parsowania JSON (display_names)
   - Bash shell (Windows: Git Bash lub WSL)

---

## Status implementacji

- [ ] Moduł 1: Contract Deployment (`contract_deploy.tf`)
- [ ] Moduł 2a: FFI Interface (`ffi_interface.tf`)
- [ ] Moduł 2b: Contract API (`contract_api.tf`)
- [ ] Moduł 3: FFListener - rozszerzenie parametryzacji (natywny)
- [ ] Moduł 4: Wallet Manager Asset (`wallet_asset.tf`)
- [ ] Moduł 5: Wallet Connections (`wallet_connections.tf`)
- [ ] Moduł 6: Display Names (`display_names.tf`)
- [ ] Utworzenie `contracts/` directory z bytecode i ABI
- [ ] Utworzenie `outputs/` directory + .gitignore
- [ ] Testy end-to-end
- [ ] Dokumentacja użycia

---

## Podsumowanie

| Typ | Ilość | Metoda |
|-----|-------|--------|
| Natywne Terraform resources | 7 | `kaleido_platform_*` |
| Curl-based resources | 6 | `null_resource` + `local-exec` |
| **RAZEM** | **13** | |

**Estymacja:** ~12-16h pracy

---

*Utworzono: 2026-01-21*
*Ostatnia aktualizacja: 2026-01-21*
