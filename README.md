# ESP32 - NodeMCU - Lua


## Erasing the Flash

In the case where `init.lua` breaks (ie. does not compile/run or causes a crash), the whole system becomes unusable and a flash reset is required to clear `init.lua` off of the chip 👍

```
./esptool.py --port /dev/tty.SLAB_USBtoUART --baud 115200 erase_flash
```

## Building Firmware

- [https://github.com/nodemcu/nodemcu-firmware/tree/dev-esp32](https://github.com/nodemcu/nodemcu-firmware/tree/dev-esp32)
- [https://nodemcu.readthedocs.io/en/dev-esp32/en/build/](https://nodemcu.readthedocs.io/en/dev-esp32/en/build/)

```
git clone --branch dev-esp32 --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git nodemcu-firmware-esp32
make menuconfig
make
make flash
```

## Connect

```
sudo cu -s 115200 -l /dev/tty.SLAB_USBtoUART
```

## Code

[https://nodemcu.readthedocs.io/en/dev-esp32/](https://nodemcu.readthedocs.io/en/dev-esp32/)

## Upload Code

### Before uploading don't forget to set the Constants.lua values

[http://chilipeppr.com/esp32](http://chilipeppr.com/esp32)

```
./serial-port-json-server
```