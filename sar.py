#!/bin/python3

import serial, sys, time

def upload_hex(hexfile, ser):
    with open(hexfile, 'r') as f: 
        for line in f:
            line = line.strip()
            if ":" not in line:
                continue
            bytes = bytearray(line, encoding="utf-8") + b'\r'
            ser.write(bytes)
            print(bytes)

    print(f"Hex file '{hexfile}' uploaded successfully!")

def run(offset, ser):
    bytes = bytearray("g", encoding="utf-8")
    ser.write(bytes)
    print(bytes)
    time.sleep(0.1)
    bytes = bytearray(' ' + str(offset) + '\r', encoding="utf-8")
    ser.write(bytes)
    print(bytes)

def hexload(ser):
    bytes = bytearray("\r", encoding="utf-8")
    ser.write(bytes)
    print(bytes)
    time.sleep(0.3)
    bytes = bytearray("hexload\r", encoding="utf-8")
    ser.write(bytes)
    print(bytes)
    time.sleep(0.1)

if __name__ == "__main__":
    hexfile = "SCM_MemTest_Z80_code8000.hex"
    if len(sys.argv) > 1:
        hexfile = sys.argv[1]
    serialport = "/dev/serial/by-id/usb-Arduino__www.arduino.cc__Arduino_USB2Serial_953333030313515101B1-if00"
    baudrate = 115200

    try:
        ser = serial.Serial(serialport, baudrate)
    except serial.SerialException as e:
        print(f"Error opening serial port {serialport}: {e}")
        exit

    hexload(ser)
    upload_hex(hexfile, ser)
    time.sleep(0.5)
    run(8000, ser)

    ser.close()
