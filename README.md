# Subasta Solidity

Este contrato Solidity implementa una subasta con depósito, reembolsos, extensión de tiempo y comisión del 2%.

## Pruebas realizadas

Las pruebas fueron parciales, pero se logró comprobar que la función `ofertar` funciona para:

- Aceptar ofertas que superan en al menos un 5% la mejor oferta anterior.
- Extender la subasta si la oferta se realiza en los últimos 10 minutos.
- Actualizar los depósitos para permitir reembolsos posteriores.

No se completaron pruebas exhaustivas de todas las funcionalidades.

## Datos del despliegue

- Dirección del contrato: `0x1348907E288F7a8Deb50457bCAf8795Bb7b94180`
- Transacción de despliegue: [Ver en Sepolia Etherscan](https://sepolia.etherscan.io/tx/0xdea50d4da381affe7c9241323a69dbe70a9cfd0ac6e990c3502b4db41c4bdbaa)
