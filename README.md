# Raw Stream Packet Analyzer (RSPA) - Unified Edition

### Project Overview
This project is a high-performance, low-level network monitoring and packet analysis suite designed natively for the Windows operating system. It operates entirely in user mode without external library dependencies by dynamically resolving Windows API functions directly from the Process Environment Block (PEB). 

In this unified edition, all three components are combined into a **single, multi-threaded executable**, eliminating disk footprint, removing named pipe overhead, and leveraging direct memory synchronization for packet processing.

---

### Architecture and Component Breakdown

#### 1. Core Orchestrator (Main Thread)
The orchestrator serves as the administrative controller and performance tuning module of the suite. It initializes the environment and ensures the payload executes with maximum CPU throughput.
* **Core Affinity and Priority Binding:** It elevates the process execution context to `REALTIME_PRIORITY_CLASS` and restricts thread execution strictly to CPU Core 0 via `SetThreadAffinityMask`. This prevents context-switching latency and guarantees dedicated hardware cycles.
* **Thread Generation:** Instead of launching external binaries, it uses dynamically resolved execution functions (`CreateThread`) to spin up the Ingestion and Processing routines concurrently within the same process space.

#### 2. Network Ingestion Subsystem (Sniffer Thread)
The ingestion subsystem interfaces directly with the Windows Sockets interface to capture live network transit data.
* **Raw Socket Initialization:** Dynamically maps and initializes the Windows Sockets subsystem (`ws2_32.dll`) via explicit `LoadLibraryA` implementation. It opens a low-level raw network socket using the `SOCK_RAW` specification.
* **Packet Capture Loop:** Intercepts raw IP packets directly from the network interface using `recvfrom`.
* **Stream Deserialization & Memory Transit:** Prepends an 8-byte metadata header containing the explicit packet size before streaming the raw payload chunk directly into a shared thread-safe ring buffer in memory.

#### 3. Data Processing Subsystem (Analyst Thread)
The processing subsystem handles the parsing and evaluation of the intercepted network data received from the ingestion buffer.
* **Buffer Consumption:** Monitors the shared memory layout using synchronized thread markers.
* **Stream Deserialization:** Reads the stream sequentially. It reads the initial 8-byte length allocation header, dynamically shifts the stack allocation constraint to match the inbound packet payload size, and reads the explicit packet data directly into the newly adjusted memory space.
* **State Verification:** Validates packet alignment metrics against fixed byte boundaries before looping back to the read cycle.

---

### Technical Implementation Merits
* **Single Binary Execution:** The entire architecture is self-contained. It leaves zero trace of multiple background tasks since it does not depend on creating or executing secondary files like `sniffer.exe` or `analyst.exe`.
* **Independent Execution:** The binary contains zero hardcoded imports. It discovers base addresses of `kernel32.dll` and `ws2_32.dll` dynamically at runtime by parsing the `InInitializationOrderModuleList` within the Process Environment Block (PEB). Function pointers are resolved manually by traversing the Export Address Table (EAT).
* **Silent Background Operation:** The module emits no console windows, standard output logs, or diagnostic visual markers, making the entire suite completely silent.

---

### Compilation, Linkage, and Installation

To build and deploy this project without any external dependencies or standard import tables, you must assemble the unified source module using NASM (Netwide Assembler) and link it using either the Microsoft Linker (`link.exe`) or the MinGW Linker (`ld.exe`) with specific compilation parameters.

#### Prerequisites
* **NASM Compiler** installed and configured within your global environment path variables.
* **Windows SDK Linker** (`link.exe`) or **MinGW toolchain** (`i686-w64-mingw32-ld`) targeting 32-bit architecture.

#### Step 1: Compiling the Source Code
Execute the following command within your terminal environment to translate your raw assembly instructions into a standalone 32-bit object file:

```bash
nasm -f win32 rspa_unified.asm -o rspa_unified.obj
```

#### Step 2: Linking the Binary
Link the generated object file using the parameters detailed below. These directives strip symbol tables, bypass standard default runtime libraries, adjust internal alignment boundaries, and enforce a quiet runtime subsystem status.

**Using Microsoft Linker (link.exe):**
```bash
link.exe /SUBSYSTEM:WINDOWS /ENTRY:_start /NODEFAULTLIB /ALIGN:16 rspa_unified.obj /OUT:rspa_unified.exe
```

**Using MinGW Linker (ld.exe):**
```bash
ld -m i386pe -e _start -s --subsystem windows rspa_unified.obj -o rspa_unified.exe
```

#### Operational Execution Flow
1. Execute `rspa_unified.exe` with Elevated Administrative Privileges (Required for low-level `SOCK_RAW` instantiation).
2. The main thread triggers real-time thread priority scheduling, targets system Core 0, and structures the shared memory block.
3. The application concurrently spawns internal background worker threads (`Sniffer Thread` and `Analyst Thread`) with detached execution parameters.
4. The sniffer thread passes intercepted payloads directly into the local memory channel, which the analyst thread continuously parses directly from stack memory allocations.
