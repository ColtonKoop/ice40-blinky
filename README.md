# Blinky: Ice40 FPGA Project Template

This is a polished template project for iCE40-based FPGAs (tested on the Go Board HX1K) using the open-source [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build). It includes synthesis, place & route, simulation, linting, formal verification, post-PNR inspection, and optional waveform viewing with GTKWave.

---

## 🔧 Requirements

### OSS CAD Suite

Install the OSS CAD Suite from YosysHQ:

```sh
wget https://github.com/YosysHQ/oss-cad-suite-build/releases/latest/download/oss-cad-suite-linux-x64.tar.gz
mkdir -p ~/tools && tar -xzf oss-cad-suite-linux-x64.tar.gz -C ~/tools
export PATH="~/tools/oss-cad-suite/bin:$PATH"
```

You can add the export line to your shell config file (e.g., `.bashrc`, `.zshrc`) for persistence.

### Go Board Constraints File

Download the constraint file from: [https://nandland.com/goboard/Go_Board_Constraints.pcf](https://nandland.com/goboard/Go_Board_Constraints.pcf)

Place it in the `constr/` directory of this project as:

```
constr/Go_Board_Constraints.pcf
```

### Other tools

- `iverilog` and `vvp` (for simulation)
- `gtkwave` (for waveform viewing)
- `verilator` (for linting)
- `iceprog` (for uploading to the Go Board)
- `sby` (optional: for formal verification with SymbiYosys)

Install via your package manager:

```sh
sudo apt install iverilog gtkwave verilator yosys
```

---

## 🗂️ Project Structure

```
├── src/            # Verilog sources
├── sim/            # Testbenches and VCD waveforms
├── constr/         # Constraint file(s)
├── formal/         # Formal verification setups
├── build/          # Auto-generated build artifacts
├── filelist.txt    # List of Verilog sources (used by tools)
├── Makefile        # Build system
└── README.md       # Project overview
```

---

## 📦 Makefile Targets (Build System)

This project is entirely driven by `make`. Below is a breakdown of all supported targets:

### ▶️ Build Flow

| Target             | Description                                                                |
| ------------------ | -------------------------------------------------------------------------- |
| `make`             | Builds the bitstream by default (runs `yosys`, `nextpnr-ice40`, `icepack`) |
| `make $(TOP).json` | Synthesizes RTL with Yosys to generate the JSON netlist                    |
| `make $(TOP).asc`  | Runs place-and-route with nextpnr (output `.asc` for bitstream)            |
| `make $(TOP).bin`  | Converts `.asc` into binary format for programming                         |

### 🔌 Programming

| Target      | Description                                                     |
| ----------- | --------------------------------------------------------------- |
| `make prog` | Uploads the generated bitstream to the Go Board using `iceprog` |

### 🧪 Simulation

| Target         | Description                                                |
| -------------- | ---------------------------------------------------------- |
| `make sim`     | Compiles and runs the testbench with `iverilog` and `vvp`  |
| `make gtkwave` | Opens the VCD waveform in GTKWave (output from `make sim`) |

### 🔬 Formal Verification (Optional)

| Target              | Description                                        |
| ------------------- | -------------------------------------------------- |
| `make formal`       | Runs SymbiYosys using the `.sby` file in `formal/` |
| `make formal-clean` | Removes the SymbiYosys working directory           |

### 🧹 Cleanup

| Target       | Description                                         |
| ------------ | --------------------------------------------------- |
| `make clean` | Deletes build artifacts, waveforms, and formal runs |

### 🔧 Debugging and Inspection

| Target           | Description                                                      |
| ---------------- | ---------------------------------------------------------------- |
| `make synthdbg`  | Generates debug outputs: synth RTL, IL, JSON, and a graph SVG    |
| `make synthview` | Opens the generated synthesis graph in a viewer (`xdg-open`)     |
| `make pnrdbg`    | Dumps the post-place-and-route netlist and explanations to files |

### ✅ Linting

| Target      | Description                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| `make lint` | Runs `verilator --lint-only` on all Verilog files, logs to `build/lint.log` |

---

## ✅ Useful Notes

- After `make`, you’ll find artifacts in `build/` such as:

  - `blinky.json` - Synthesized netlist
  - `blinky.asc`  - Place & route result
  - `blinky.bin`  - Final bitstream
  - `blinky.log`  - Full nextpnr output

- Constraint file must match your Go Board IO — double-check `.pcf` if your design isn’t working.

- Use `make pnrdbg` to inspect how your design was actually implemented.

- 🔄 **Use `filelist.txt`** to manage which source files get compiled. This improves maintainability in larger projects.

---

## 🚀 Getting Started

```sh
git clone <this-repo-url>
cd ice40-blinky
echo 'src/blinky.v\nsrc/led_driver.v' > filelist.txt
make       # Build bitstream
make prog  # Upload to FPGA
```

Want to test your design in simulation?

```sh
make sim
make gtkwave
```

---

## 🧩 Want to Extend It?

- Add more modules in `src/`
- Write new testbenches in `sim/`
- Add more constraints to the `.pcf`
- Try new synthesis passes in `synthdbg`
- Add formal proof blocks to `formal/`

---

Happy hacking with open FPGAs! 💡
