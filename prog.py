import os
import subprocess
import platform
from pathlib import Path

def find_oss_cad_suite_bin():
    env_bin = os.environ.get("OSSCAD_BIN")
    if env_bin and Path(env_bin).exists:
        return (env_bin)
    
    candidates = [
        Path("C:/oss-cad-suite/bin"),
        Path.home() / ".apio/packages/oss-cad-suite/bin",
        Path.home() / "oss-cad-suite/bin",
    ]

    for c in candidates:
        if c.exists():
            return c
    
    raise FileNotFoundError("Could not locate OSS-CAD-Suite. "
                            "Set OSSCAD_BIN enviornment variable. ")

def find_bit_file():
    bit_path = Path("./src/_build/default/hardware.bit")
    if bit_path.exists():
        return bit_path
    
    raise FileNotFoundError("bit not found. Please use apio ot build the bit file")

def get_executable_name():
    system = platform.system()
    if system == "Windows":
        return "openFPGALoader.exe"
    else:
        return "openFPGALoader"

def prog(suite_bin, bit_file):
    print("Starting programming process. 🔃")
    start_bat = suite_bin.parent / "environment.bat"
    openFPGALoader_cmd = f"openFPGALoader -c -cmsis-dap -b colorlight-i5 {bit_file}"
    if not start_bat.exists():
        raise FileNotFoundError(f"start.bat not found in {suite_bin.parent}")
    
    try:
        _ =subprocess.run(
            f'cmd /c " call {start_bat} && {openFPGALoader_cmd}"',
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
            )
        
        print("Bit file successfully loaded to the FPGA. ✅")
    except subprocess.CalledProcessError as e:
        print("Failed to load bit file: ", e)

if __name__ == "__main__":
    suite_bin = find_oss_cad_suite_bin()
    bit_file = find_bit_file()
    prog(suite_bin, bit_file)