# Define pastas e arquivos
$structure = @(
    "lib/core/constants/app_constants.dart",
    "lib/core/exceptions/api_exception.dart",
    "lib/core/utils/http_client_factory.dart",

    "lib/data/models/drug_dto.dart",
    "lib/data/models/cart_item_dto.dart",
    "lib/data/repositories/drug_repository_impl.dart",
    "lib/data/repositories/cart_repository_impl.dart",
    "lib/data/services/api_service.dart",
    "lib/data/services/adapters/drug_adapter.dart",
    "lib/data/services/adapters/cart_item_adapter.dart",

    "lib/domain/entities/drug.dart",
    "lib/domain/entities/cart_item.dart",
    "lib/domain/usecases/get_drugs_usecase.dart",
    "lib/domain/usecases/get_cart_usecase.dart",
    "lib/domain/usecases/add_to_cart_usecase.dart",
    "lib/domain/usecases/update_cart_item_usecase.dart",
    "lib/domain/usecases/remove_cart_item_usecase.dart",

    "lib/presentation/providers/drug_provider.dart",
    "lib/presentation/providers/cart_provider.dart",
    "lib/presentation/pages/drug_list_page.dart",
    "lib/presentation/pages/drug_detail_page.dart",
    "lib/presentation/pages/cart_page.dart",
    "lib/presentation/widgets/drug_card.dart",
    "lib/presentation/widgets/cart_item_tile.dart",
    "lib/presentation/widgets/quantity_selector.dart",

    "lib/main.dart",
    "lib/app.dart",
    "lib/di.dart",

    "test/data/repositories/drug_repository_impl_test.dart",
    "test/data/repositories/cart_repository_impl_test.dart",
    "test/domain/usecases/get_drugs_usecase_test.dart",
    "test/domain/usecases/add_to_cart_usecase_test.dart",
    "test/presentation/pages/drug_list_page_test.dart",
    "test/presentation/pages/cart_page_test.dart"
)

# Cria pastas e arquivos
foreach ($path in $structure) {
    $fullPath = Join-Path -Path $PWD -ChildPath $path
    $folder = Split-Path $fullPath -Parent
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
    if (!(Test-Path $fullPath)) {
        New-Item -ItemType File -Path $fullPath -Force | Out-Null
    }
}

Write-Host "✅ Estrutura do projeto Flutter criada com sucesso!"
