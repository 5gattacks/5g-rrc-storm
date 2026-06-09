# 5G RRC Storm Attack and Mitigation

This repository contains the scripts, patches, and NMS used to run the RRC storm attack and the proposed mitigation using OpenAirInterface.

The attack and mitigation are both based on OpenAirInterface commit:

```bash
92980ceb725a94dbfe97c509d16f1313eee083e0
```

## 1. Clone the repository

```bash
git clone https://github.com/5gattacks/5g-rrc-storm.git ~/5g-rrc-storm
cd ~/5g-rrc-storm
```

## 2. Build the mitigated gNB

Run:

```bash
cd ~/5g-rrc-storm
./scripts/build-mitigation.sh
```

This script clones OAI inside `~/openairinterface5g` if needed, checks out the base commit, applies `storm-mitigation.patch`, installs OAI dependencies, and builds the gNB/UE binaries.


## 3. Build the attack UE

Run:

```bash
cd ~/5g-rrc-storm
./scripts/build-attacker.sh
```

This script clones OAI inside `~/rrc-storm-attack` if needed, checks out the base commit, applies `storm-attack.patch`, installs OAI dependencies, and builds the attack UE.


## 4. Start the OAI 5G Core

The OAI 5G Core is expected to be located in:

```bash
~/oai-cn5g
```

Start the core:

```bash
cd ~/5g-rrc-storm
./scripts/start-core.sh
```

To stop the core:

```bash
cd ~/5g-rrc-storm
./scripts/stop-core.sh
```

## 5. Capture AMF logs

The NMS reads AMF logs from:

```bash
~/oai-cn5g/amf.logs
```

Start AMF log capture in a separate terminal:

```bash
cd ~/5g-rrc-storm
./scripts/log-amf.sh
```

## 6. Start the NMS

The NMS uses the Docker images:

```bash
5gsecurity/nms-backend:latest
5gsecurity/nms-frontend:latest
```

Start the NMS:

```bash
cd ~/5g-rrc-storm
./start-nms.sh
```

Open the web interface:

```bash
http://localhost:3000
```

Stop the NMS:

```bash
cd ~/5g-rrc-storm
./stop-nms.sh
```

If the OAI core Docker network exists, the NMS starts attached to it. This allows the SIM/subscriber page to access the core database.

If the core network is not running, the NMS can still start, but the SIM/subscriber page may not work.

Note that this NMS is the new version of our previous code for [SIB8 alert message](https://github.com/5gattacks/5g-sib8-alert.git).
## 7. Run the mitigated gNB

For RF simulator mode, run:

```bash
cd ~/5g-rrc-storm
./scripts/run-gnb-mitigation-rfsim.sh
```

This starts the mitigated gNB from:

```bash
~/openairinterface5g
```

and writes the filtered gNB logs to:

```bash
~/openairinterface5g/gnb.logs
```

The NMS reads this file to update the dashboard.

For SDR mode with USRP B210, run:

```bash
cd ~/5g-rrc-storm
./scripts/run-gnb-mitigation.sh
```

## 8. Run the attack UE

For RF simulator mode, run:

```bash
cd ~/5g-rrc-storm
./scripts/run-attacker-ue-rfsim.sh
```

This starts the attack UE from:

```bash
~/rrc-storm-attack
```

For SDR mode with USRP B210, run:

```bash
cd ~/5g-rrc-storm
./scripts/run-attacker-ue.sh
```

Make sure the UE parameters match the gNB configuration:

```bash
--C
-r
--numerology
--ssb
--band
```

## 9. Run order

Use separate terminals.

### Terminal 1: Core network

```bash
cd ~/5g-rrc-storm
./scripts/start-core.sh
```

### Terminal 2: AMF logs

```bash
cd ~/5g-rrc-storm
./scripts/log-amf.sh
```

### Terminal 3: NMS

```bash
cd ~/5g-rrc-storm
./start-nms.sh
```

Open:

```bash
http://localhost:3000
```

### Terminal 4: Mitigated gNB

```bash
cd ~/5g-rrc-storm
./scripts/run-gnb-mitigation-rfsim.sh
```

### Terminal 5: Attack UE

```bash
cd ~/5g-rrc-storm
./scripts/run-attacker-ue-rfsim.sh
```

## 10. Stop everything

Stop the UE and gNB using:

```bash
Ctrl+C
```

Stop the NMS:

```bash
cd ~/5g-rrc-storm
./stop-nms.sh
```

Stop the core:

```bash
cd ~/5g-rrc-storm
./scripts/stop-core.sh
```

## 11. Configurable constants

Some constants can be modified before rebuilding OAI.

### Mitigation detection constants

File:

```bash
~/openairinterface5g/openair2/RRC/NR/nr_rrc_defs.h
```

Constants:

```c
#define STORM_WIN_MS              1025
#define STORM_SLOT_MS             25
#define STORM_NUM_SLOTS           (STORM_WIN_MS / STORM_SLOT_MS)

#define STORM_R2_START_THRES      50
#define STORM_R2_STOP_THRES       70
#define STORM_MIN_MSG4            8
```

Meaning:

- `STORM_WIN_MS`: detection window duration.
- `STORM_SLOT_MS`: time granularity of the detection window.
- `STORM_R2_START_THRES`: threshold used to detect the storm.
- `STORM_R2_STOP_THRES`: threshold used to mark the storm as ended.
- `STORM_MIN_MSG4`: minimum number of Msg4 transmissions required before detection is allowed.

### TA bucket constants

File:

```bash
~/openairinterface5g/openair2/RRC/NR/nr_rrc_defs.h
```

Constants:

```c
#define NR_TA_BUCKET_WIDTH        2
#define NR_TA_NUM_BUCKETS         4
```

Meaning:

- `NR_TA_BUCKET_WIDTH`: number of TA values grouped in one bucket.
- `NR_TA_NUM_BUCKETS`: number of TA buckets used by the mitigation.

### Suspicious bucket waiting time

File:

```bash
~/openairinterface5g/openair2/RRC/NR/rrc_gNB.c
```

Value:

```c
uint32_t timeout_ms = 100;
```

Meaning:

- waiting time given to a UE from the suspicious TA bucket to complete RRC setup before it is released.

### Attack timer

File:

```bash
~/rrc-storm-attack/openair2/RRC/NR_UE/rrc_timers_and_constants.c
```

Timer setup:

```c
nr_timer_setup(&tac->attack_rach_timer, 10, 10);
```

Meaning:

- controls how quickly the attack UE repeats the RRC access attempt. (This is required in the SDR setup to give time for acknowledgment.)

After changing constants, rebuild the corresponding OAI version.

For mitigation changes:

```bash
cd ~/openairinterface5g/cmake_targets
./build_oai -w USRP --ninja --nrUE --gNB --build-lib "nrscope" -C
```

For attack changes:

```bash
cd ~/rrc-storm-attack/cmake_targets
./build_oai -w USRP --ninja --nrUE --gNB --build-lib "nrscope" -C
```

## Disclaimer

This repository is intended only for controlled experiments in a private 5G testbed. Do not run the attack against public networks or systems you do not own or have explicit permission to test.
