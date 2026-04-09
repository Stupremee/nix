"""Application entrypoint."""

from __future__ import annotations

import argparse
import asyncio
import contextlib
import logging
from pathlib import Path

from .config import AppConfig
from .ha_client import HomeAssistantClient
from .logging_utils import configure_logging
from .modbus_server import serve_modbus_tcp
from .register_store import SunSpecRegisterStore


LOGGER = logging.getLogger(__name__)


async def _poll_home_assistant_loop(
    *,
    app_config: AppConfig,
    store: SunSpecRegisterStore,
) -> None:
    """Poll Home Assistant states and map them into the in-memory register store."""
    token = Path(app_config.home_assistant.token_file).read_text(encoding="utf-8").strip()
    client = HomeAssistantClient(app_config.home_assistant, token)
    try:
        current_values = store.get_dynamic_values()
        while True:
            try:
                current_values = await client.fetch_values(previous_values=current_values)
                store.update_dynamic_values(current_values)
                LOGGER.info(
                    "Home Assistant refresh succeeded for %s mapped entities",
                    len(app_config.home_assistant.entity_mappings),
                )
            except Exception:
                LOGGER.exception("Home Assistant refresh failed")
            await asyncio.sleep(app_config.poll_interval_seconds)
    finally:
        await client.close()


async def run_app(app_config: AppConfig) -> None:
    """Run the full application."""
    configure_logging(app_config.log_level)
    LOGGER.info("Starting SunSpec Modbus server with config %s", app_config.redacted_summary())

    if app_config.data_source == "homeAssistant":
        for key, mapping in sorted(app_config.home_assistant.entity_mappings.items()):
            LOGGER.info(
                "Mapping Home Assistant entity %s to %s with scale %s and negate %s",
                mapping.entity_id,
                key,
                mapping.scale,
                mapping.negate,
            )
    else:
        LOGGER.info("Using dummy values for all SunSpec measurements")

    store = SunSpecRegisterStore(
        unit_id=app_config.unit_id,
        base_address=app_config.base_address,
        poll_interval_seconds=app_config.poll_interval_seconds,
        initial_values=app_config.dummy_values,
    )

    async with asyncio.TaskGroup() as task_group:
        task_group.create_task(
            serve_modbus_tcp(
                store=store,
                host=app_config.host,
                port=app_config.port,
                unit_id=app_config.unit_id,
            )
        )
        if app_config.data_source == "homeAssistant":
            task_group.create_task(
                _poll_home_assistant_loop(
                    app_config=app_config,
                    store=store,
                )
            )


def build_arg_parser() -> argparse.ArgumentParser:
    """Build the CLI argument parser."""
    parser = argparse.ArgumentParser(description="SunSpec-compatible Modbus TCP server")
    parser.add_argument("--config", help="Path to JSON configuration file")
    parser.add_argument(
        "--dummy",
        action="store_true",
        help="Ignore config and start immediately with built-in dummy values",
    )
    parser.add_argument(
        "--home-assistant-token-file",
        dest="home_assistant_token_file",
        help="Override the Home Assistant token file path from the config",
    )
    return parser


def main() -> None:
    """CLI entrypoint."""
    args = build_arg_parser().parse_args()
    if args.dummy:
        app_config = AppConfig.dummy_default()
    else:
        if not args.config:
            raise SystemExit("--config is required unless --dummy is used")
        app_config = AppConfig.from_json_file(
            args.config,
            home_assistant_token_file_override=args.home_assistant_token_file,
        )
    with contextlib.suppress(KeyboardInterrupt):
        asyncio.run(run_app(app_config))


if __name__ == "__main__":
    main()
