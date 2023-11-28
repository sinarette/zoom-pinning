from scapy.all import *
import argparse

def findVideoPort(iface):
    t = AsyncSniffer(iface=iface, timeout=1, filter="udp")
    t.start()
    print("Looking For Zoom Video Port...")
    port = 0
    try:
        while port == 0:
            t.join()
            pcap = t.results
            t.start()
            for packet in pcap:
                if not UDP in packet or not Raw in packet: continue
                payload = bytes(packet[UDP].payload)
                if payload[0] == 0x05 and payload[8] == 0x10 and payload[33] & 0x7f == 0x62:
                    myport = packet[UDP].sport
                    if myport == 8801: myport = packet[UDP].dport
                    if port != 0 and port == myport: break
                    port = myport
    except KeyboardInterrupt:
        t.join()
        exit()
    t.join()

    print(port)
    return port
    

def watch(iface, port):
    t = AsyncSniffer(iface=iface, timeout=1, filter=f"udp dst port {port}")
    t.start()
    counter = 0
    watchers = {}
    try:
        while True:
            viewers = {}
            t.join()
            pcap = t.results
            t.start()

            for packet in pcap:
                if not UDP in packet or not Raw in packet: continue
                payload = bytes(packet[UDP].payload)

                if payload[0] == 0x05 and payload[8] == 0x20:
                    id = payload[15:17].hex()
                    quality = payload[27]
                    watchers[id] = (quality, counter)

                if payload[0] == 0x05 and payload[8] == 0x10 and payload[33] & 0x7f == 0x62:   
                    id = payload[41:43].hex()
                    quality = payload[54] & 3
                    viewers[id] = quality

            drawResults(watchers, viewers, counter)
            
            counter += 1
    except KeyboardInterrupt:
        t.join()
        exit(1)


def drawResults(watchers, viewers, counter):
    os.system('clear')

    print("Who's Watching You? (Recent Confirmed)")
    printQ = [[], [], []]

    for id in watchers:
        (q, c) = watchers[id]
        if counter > c + 99: continue
        printQ[q].append((id, counter-c))


    print('HIGH: ', end='')
    for (id, c) in printQ[2]: print(f'{id}({c}s)', end='  ')
    print('\nMED:  ', end='')
    for (id, c) in printQ[1]: print(f'{id}({c}s)', end='  ')
    print('\nLOW:  ', end='')
    for (id, c) in printQ[0]: print(f'{id}({c}s)', end='  ')

    printQ = [[], [], []]
    for id in viewers:
        q = viewers[id]
        printQ[q].append(id)

    print("\nWho You're Watching")
    print('HIGH: ', end='')
    for id in printQ[2]: print(id, end='  ')
    print('\nMED:  ', end='')
    for id in printQ[1]: print(id, end='  ')
    print('\nLOW:  ', end='')
    for id in printQ[0]: print(id, end='  ')
    print('')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-i', '--iface', help='Interface', default='eth0')

    args = parser.parse_args()
    iface = args.iface

    port = findVideoPort(iface)

    watch(iface, port)