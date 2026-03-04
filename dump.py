#!/bin/python3

import serial, sys, time

if __name__ == "__main__":
    hexfile = "dump.hex"
    if len(sys.argv) > 1:
        hexfile = sys.argv[1]
    serialport = "/dev/serial/by-id/usb-Arduino__www.arduino.cc__Arduino_USB2Serial_953333030313515101B1-if00"
    baudrate = 115200

    try:
        ser = serial.Serial(serialport, baudrate)
    except serial.SerialException as e:
        print(f"Error opening serial port {serialport}: {e}")
        exit

    with open(hexfile, 'w') as f:

        bytes = bytearray("dump\r", encoding="utf-8")
        ser.write(bytes)
        while True:
            line = ser.readline()
            line = line.decode('utf-8')
            print(line, end='')
            f.write(line)
            if line == ":00000001FF\r\n":
                break

    ser.close()
