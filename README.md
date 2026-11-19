# Reto 4: El Convertidor de Criptomonedas "En Tiempo Real"

App Flutter que usa la API pública y **sin autenticación** de
[CoinGecko](https://www.coingecko.com/en/api) para mostrar el precio actual de
Bitcoin, Ethereum y Solana en dólares. El usuario escribe un monto en USD y ve
cuántas fracciones de cada cripto compraría. Los precios se refrescan cada minuto
y también con el botón de actualizar o deslizando la lista hacia abajo.

Endpoint usado:

```
GET https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd
```

## Arquitectura

Clean Architecture; la dependencia siempre apunta hacia `domain`.

```
lib/
├── core/
│   ├── constants/api_constants.dart
│   ├── error/        (exceptions.dart, failures.dart)
│   └── utils/        (formatters.dart: formatUsd)
├── features/crypto/
│   ├── domain/
│   │   ├── entities/      Crypto, CryptoPrice
│   │   ├── repositories/  CryptoRepository (contrato)
│   │   └── usecases/      GetCryptoPrices, CalculateCryptoAmount
│   ├── data/
│   │   ├── datasources/   CryptoRemoteDataSource (HTTP)
│   │   ├── models/        CryptoPriceModel (fromJson)
│   │   └── repositories/  CryptoRepositoryImpl
│   └── presentation/      CryptoProvider · CryptoPage · CryptoCard
└── main.dart              (inyección de dependencias)
```

La cuenta `monto ÷ precio` vive en el caso de uso `CalculateCryptoAmount`, por
eso es fácil de probar sin Flutter ni red.

## Cómo ejecutarlo

No necesita API key.

```bash
flutter create . --project-name reto4_convertidor_cripto --platforms=android,ios,windows,web
flutter pub get
flutter test
flutter run -d windows     # o macos / linux / chrome
```

En Android agrega el permiso de internet en
`android/app/src/main/AndroidManifest.xml`, arriba de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

La API gratuita de CoinGecko tiene límite de peticiones. Si ves el aviso de
"Demasiadas consultas", espera un minuto y vuelve a intentar.

## Capturas

_Agrega aquí capturas de la app funcionando._
