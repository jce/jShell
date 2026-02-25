#!/bin/python3

import math

if __name__ == "__main__":
    
    period = 256
    table_len = 256
    min = 16
    max = 240

    for i in range(table_len):
        angle = (i / period) * 2 * math.pi
        val = int(min +  (1 + math.sin(angle)) / 2  * (max-min) )
        print( str(val) + ", " ,end='' )
    print("\b\b  ")


