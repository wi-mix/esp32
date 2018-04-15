# ESP32 - NodeMCU - Lua

## 1. Download tools

### USB Driver

Download and install the correct drivers for your OS

- [https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)

### Serial port json server

Download the latest release for your OS

- [https://github.com/johnlauer/serial-port-json-server/releases](https://github.com/johnlauer/serial-port-json-server/releases)

### esptool

Download the esptool source

```Bash
git clone https://github.com/espressif/esptool.git esptool
```

### nodemcu

Download the NodeMCU source

```Bash
git clone --branch dev-esp32 --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git nodemcu-firmware-esp32
```

## 2. Erasing the Flash

In the case where `init.lua` breaks (ie. does not compile/run or causes a crash), the whole system becomes unusable and a flash reset is required to clear `init.lua` off of the chip 👍

```
esptool/esptool.py --port /dev/tty.SLAB_USBtoUART --baud 115200 erase_flash
```

## 3. Building and Uploading Firmware

- [https://nodemcu.readthedocs.io/en/dev-esp32/en/build/](https://nodemcu.readthedocs.io/en/dev-esp32/en/build/)

```
cd nodemcu-firmware-esp32
make menuconfig
make
make flash
```

## 4. Writing Code

### NodeMCU API Documentation

- [https://nodemcu.readthedocs.io/en/dev-esp32/](https://nodemcu.readthedocs.io/en/dev-esp32/)

### Lua IDE

- [http://chilipeppr.com/esp32](http://chilipeppr.com/esp32)

Run the local json server and connect to it in the IDE

```Bash
./serial-port-json-server
```

# Notes

- All code in chilipeppr is save to local storage, and needs to be manually copied to files for source control.
- Chilipeppr uploads the files one line at a time using Lua's multiline string literal (`[[ ... ]]`), which means you cannot use it in your code.
- If the board is constantly crashing, it needs to be wiped ([Erasing the Flash](#2-erasing-the-flash))
