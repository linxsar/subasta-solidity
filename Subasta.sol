// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Contrato de una subasta con tiempo límite, extensión por oferta tardía,
// historial de ofertas, reembolsos y comisión para el organizador.
contract Subasta {
    // Dirección del creador de la subasta
    address public dueno;

    // Momento en el que finaliza la subasta (timestamp)
    uint public finSubasta;

    // Dirección del mejor postor actual
    address public mejorPostor;

    // Monto de la mejor oferta
    uint public mejorOferta;

    // Comisión que se queda el dueño (2%)
    uint public constanteComision = 2;

    // Indica si la subasta fue finalizada
    bool public finalizada;

    // Estructura para guardar las ofertas
    struct Oferta {
        address oferente;
        uint monto;
    }

    // Lista con todas las ofertas válidas
    Oferta[] public historialOfertas;

    // Mapeo para guardar cuánto puede retirar cada persona
    mapping(address => uint) public depositos;

    // Evento que se dispara cuando alguien hace una nueva oferta válida
    event NuevaOferta(address indexed oferente, uint monto);

    // Evento que se dispara al finalizar la subasta
    event SubastaFinalizada(address ganador, uint montoGanador);

    // Constructor: se pasa la duración de la subasta en minutos
    constructor(uint _duracionEnMinutos) {
        require(_duracionEnMinutos > 0, "La duracion debe ser mayor a 0");
        dueno = msg.sender;
        finSubasta = block.timestamp + (_duracionEnMinutos * 1 minutes);
    }

    // Función para ofertar en la subasta
    function ofertar() public payable {
        require(block.timestamp < finSubasta, "La subasta ha finalizado");
        require(msg.value > 0, "Debes enviar ETH para ofertar");

        // La nueva oferta debe superar al menos un 5% a la anterior
        require(
            msg.value >= mejorOferta + (mejorOferta * 5) / 100 || mejorOferta == 0,
            "La oferta debe superar al menos en un 5% a la mejor oferta"
        );

        // Si había una oferta anterior, se guarda para reembolso
        if (mejorPostor != address(0)) {
            depositos[mejorPostor] += mejorOferta;
        }

        // Se actualiza la mejor oferta
        mejorPostor = msg.sender;
        mejorOferta = msg.value;

        // Se guarda en el historial
        historialOfertas.push(Oferta(msg.sender, msg.value));

        // Si se oferta en los últimos 10 minutos, se extiende la subasta
        if (finSubasta - block.timestamp <= 10 minutes) {
            finSubasta += 10 minutes;
        }

        emit NuevaOferta(msg.sender, msg.value);
    }

    // Permite retirar saldo acumulado antes de que termine la subasta
    function retirarExceso() public {
        require(block.timestamp < finSubasta, "Solo se puede retirar durante la subasta");

        uint monto = depositos[msg.sender];
        require(monto > 0, "No tienes saldo para retirar");

        depositos[msg.sender] = 0;
        payable(msg.sender).transfer(monto);
    }

    // Finaliza la subasta y paga al dueño menos comisión
    function finalizarSubasta() public {
        require(block.timestamp >= finSubasta, "La subasta aun no ha finalizado");
        require(!finalizada, "La subasta ya fue finalizada");

        finalizada = true;

        uint comision = (mejorOferta * constanteComision) / 100;
        uint pagoDueno = mejorOferta - comision;

        payable(dueno).transfer(pagoDueno);

        emit SubastaFinalizada(mejorPostor, mejorOferta);
    }

    // Permite a los perdedores retirar su dinero después de que termina la subasta
    function retirarPerdedores() public {
        require(finalizada, "La subasta aun no ha finalizado");
        require(msg.sender != mejorPostor, "El ganador no puede retirar deposito");

        uint monto = depositos[msg.sender];
        require(monto > 0, "No tienes saldo para retirar");

        depositos[msg.sender] = 0;
        payable(msg.sender).transfer(monto);
    }

    // Devuelve todas las ofertas realizadas (válidas)
    function obtenerHistorial() public view returns (Oferta[] memory) {
        return historialOfertas;
    }

    // Muestra quién va ganando y con cuánto
    function verGanadorActual() public view returns (address, uint) {
        return (mejorPostor, mejorOferta);
    }

    // Indica si la subasta sigue activa
    function subastaActiva() public view returns (bool) {
        return block.timestamp < finSubasta && !finalizada;
    }

    // Permite ver el saldo que tiene guardado un usuario
    function verDeposito(address participante) public view returns (uint) {
        return depositos[participante];
    }
}
