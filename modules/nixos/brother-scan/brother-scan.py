#!/usr/bin/env python3
# "Scan to PC" receiver for Brother network scanners.
# Registers this host as a scan target via SNMP (like Brother's brscan-skey),
# waits for the button press notification over UDP, then pulls the scan with
# the brscan4 SANE backend and writes one PDF per button press to OUT_DIR.
# Afterwards every *.sh in HOOKS_DIR runs (in name order) with the PDF path as $1.
# The printer shows "PC-Anschluss" after the button press and only accepts
# Brother's own scan protocol then, so eSCL does not work here.
# Expects scanimage (with brscan4 configured), snmpset, img2pdf and bash on
# PATH and is configured through the environment variables read below.
import os
import socket
import subprocess
import tempfile
import threading
import time
from datetime import datetime
from pathlib import Path

PRINTER = os.environ["PRINTER"]
HOST_IP = os.environ["HOST_IP"]
NAME = os.environ["TARGET_NAME"]
OUT_DIR = Path(os.environ["OUT_DIR"])
HOOKS_DIR = Path(os.environ["HOOKS_DIR"])
HOOK_TIMEOUT = 600
PORT = 54925
DEVICE = "brother4:net1;dev0"
OID = "1.3.6.1.4.1.2435.2.3.9.2.11.1.1.0"
FUNCS = {"IMAGE": 1, "EMAIL": 2, "OCR": 3, "FILE": 5}


def log(msg: str) -> None:
    print(msg, flush=True)


def register_forever() -> None:
    # The printer forgets targets after DURATION seconds, so re-register before that.
    while True:
        for func, appnum in FUNCS.items():
            value = (
                f'TYPE=BR;BUTTON=SCAN;USER="{NAME}";FUNC={func};'
                f"HOST={HOST_IP}:{PORT};APPNUM={appnum};DURATION=360;CC=1;"
            )
            result = subprocess.run(
                ["snmpset", "-v1", "-c", "internal", PRINTER, OID, "s", value],
                capture_output=True,
                text=True,
            )
            if result.returncode != 0:
                log(f"register {func} failed: {result.stderr.strip()}")
        time.sleep(300)


def scan_pages(source: str, workdir: Path) -> list[Path]:
    # --batch keeps pulling pages until the ADF is empty (FlatBed stops after one).
    # Right after the button press the printer sometimes refuses the first open
    # ("Invalid argument"), so retry a few times.
    for attempt in range(5):
        result = subprocess.run(
            [
                "scanimage", "-d", DEVICE, "--source", source,
                "--mode", "True Gray", "--resolution", "300",
                "-x", "210", "-y", "297",  # A4
                "--format", "png", f"--batch={workdir}/page-%03d.png",
                *(["--batch-count=1"] if source == "FlatBed" else []),
            ],
            capture_output=True,
            text=True,
        )
        status = result.stderr.strip().splitlines()[-1:]
        if "open of device" not in result.stderr:
            break
        log(f"{source}: open failed (attempt {attempt + 1}), retrying")
        time.sleep(2)
    pages = sorted(workdir.glob("page-*.png"))
    log(f"{source}: {len(pages)} page(s), scanimage: {status}")
    return pages


def scan() -> Path | None:
    stamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        workdir = Path(tmp)
        pages = scan_pages("Automatic Document Feeder(left aligned)", workdir)
        if not pages:  # ADF empty, fall back to the glass
            pages = scan_pages("FlatBed", workdir)
        if not pages:
            log("no pages received")
            return None
        out = OUT_DIR / f"scan_{stamp}.pdf"
        subprocess.run(["img2pdf", *map(str, pages), "-o", str(out)], check=True)
        log(f"saved {out} ({len(pages)} page(s))")
        return out


def run_hooks(pdf: Path) -> None:
    # Hooks are picked up fresh for every scan, so adding or removing one needs
    # no restart. A failing hook is logged and does not stop the others.
    for hook in sorted(HOOKS_DIR.glob("*.sh")):
        try:
            result = subprocess.run(["bash", str(hook), str(pdf)], timeout=HOOK_TIMEOUT)
            log(f"hook {hook.name}: exit {result.returncode}")
        except subprocess.TimeoutExpired:
            log(f"hook {hook.name}: timed out after {HOOK_TIMEOUT}s")


def main() -> None:
    threading.Thread(target=register_forever, daemon=True).start()
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", PORT))
    log(f"listening on :{PORT}, saving to {OUT_DIR}, hooks in {HOOKS_DIR}")
    last = b""
    while True:
        data, addr = sock.recvfrom(2048)
        log(f"from {addr[0]}: {data!r}")
        # The printer repeats each notification (same SEQ); react once.
        if b"BUTTON=SCAN" not in data or data == last:
            continue
        last = data
        try:
            pdf = scan()
        except Exception as e:  # keep listening after a failed scan
            log(f"scan failed: {e!r}")
            continue
        if pdf:
            run_hooks(pdf)


if __name__ == "__main__":
    main()
