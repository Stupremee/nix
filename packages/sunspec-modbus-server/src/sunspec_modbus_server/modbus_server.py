"""Async Modbus TCP server with write-focused request logging."""

from __future__ import annotations

import logging
from typing import Any

from pymodbus.datastore import ModbusDeviceContext, ModbusServerContext
from pymodbus.pdu.device import ModbusDeviceIdentification
from pymodbus.server.requesthandler import ServerRequestHandler
from pymodbus.server.server import ModbusTcpServer

from .register_store import SunSpecHoldingRegisterBlock, SunSpecRegisterStore


LOGGER = logging.getLogger(__name__)


def _format_remote(addr: Any) -> str:
    if isinstance(addr, tuple) and len(addr) >= 2:
        return f"{addr[0]}:{addr[1]}"
    return "unknown"


def _request_span(pdu: Any) -> tuple[int, int]:
    if hasattr(pdu, "write_address") and hasattr(pdu, "write_count"):
        return int(pdu.write_address), int(pdu.write_count)
    if hasattr(pdu, "address"):
        count = int(getattr(pdu, "count", 1) or 1)
        return int(pdu.address), count
    return 0, 0


class LoggingRequestHandler(ServerRequestHandler):
    """Request handler that logs Modbus writes without spamming read traffic."""

    def _log_request(self) -> None:
        if not self.last_pdu:
            return
        start, count = _request_span(self.last_pdu)
        remote = _format_remote(self.last_addr)
        if self.last_pdu.function_code in {6, 16, 23}:
            LOGGER.info(
                "Modbus write remote=%s unit_id=%s function_code=%s start=%s count=%s",
                remote,
                self.last_pdu.dev_id,
                self.last_pdu.function_code,
                start,
                count,
            )

    async def handle_request(self):
        self._log_request()
        return await super().handle_request()


class LoggingModbusTcpServer(ModbusTcpServer):
    """Modbus TCP server that attaches the logging request handler."""

    def callback_new_connection(self):
        return LoggingRequestHandler(
            self,
            self.trace_packet,
            self.trace_pdu,
            self.trace_connect,
        )


async def serve_modbus_tcp(
    *,
    store: SunSpecRegisterStore,
    host: str,
    port: int,
    unit_id: int,
) -> None:
    """Run the async Modbus TCP server forever."""
    context = ModbusServerContext(
        devices={
            unit_id: ModbusDeviceContext(
                hr=SunSpecHoldingRegisterBlock(store),
            )
        },
        single=False,
    )
    identity = ModbusDeviceIdentification(
        info_name={
            "VendorName": "NixOS",
            "ProductCode": "SUNSPEC-HA",
            "MajorMinorRevision": "0.1.0",
            "VendorUrl": "https://github.com/justuskliem/nix",
            "ProductName": "SunSpec Modbus Server",
            "ModelName": "Virtual SunSpec Device",
            "UserApplicationName": "sunspec-modbus-server",
        }
    )
    server = LoggingModbusTcpServer(
        context,
        identity=identity,
        address=(host, port),
    )
    await server.serve_forever()
