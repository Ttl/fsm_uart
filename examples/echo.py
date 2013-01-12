import serial
import sys
BAUDRATE = 115200
PARITY = True

#Configures serial port
def configure_serial(serial_port):
    return serial.Serial(
        port=serial_port,
        baudrate=BAUDRATE,
        parity=serial.PARITY_EVEN if PARITY else serial.PARITY_NONE,
        stopbits=serial.STOPBITS_TWO,
        bytesize=serial.EIGHTBITS,
        timeout=1
    )

if __name__ == "__main__":

    if len(sys.argv)!=2:
        print "Give serial port address as a command line argument."
        exit()
    try:
        ser = configure_serial(sys.argv[1])
        if not ser.isOpen():
            raise Exception
    except:
        print 'Opening serial port {} failed.'.format(sys.argv[1])
        raise
        exit()

    while True:
        c = raw_input()
        for i in c:
            ser.write(i)
            print ser.read(1)

