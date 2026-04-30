import numpy as np
import time
import random

p1_0 = list(range(5, 0, -1))
p2_0 = []
p3_0 = []

p3_obj = list(range(5, 0, -1))

last_move = None  # (from, to)

def can_move(src, dst):
    return len(src) > 0 and (len(dst) == 0 or src[-1] < dst[-1])

def do_move(src, dst, name_src, name_dst):
    global last_move
    dst.append(src.pop())
    last_move = (name_src, name_dst)

while p3_0 != p3_obj:

    # p1 → p2
    if can_move(p1_0, p2_0) and last_move != ("p2", "p1"):
        do_move(p1_0, p2_0, "p1", "p2")

    # p1 → p3
    elif can_move(p1_0, p3_0) and last_move != ("p3", "p1"):
        do_move(p1_0, p3_0, "p1", "p3")

    # p2 → p1
    elif can_move(p2_0, p1_0) and last_move != ("p1", "p2"):
        do_move(p2_0, p1_0, "p2", "p1")

    # p2 → p3
    elif can_move(p2_0, p3_0) and last_move != ("p3", "p2"):
        do_move(p2_0, p3_0, "p2", "p3")

    # p3 → p1
    elif can_move(p3_0, p1_0) and last_move != ("p1", "p3"):
        do_move(p3_0, p1_0, "p3", "p1")

    # p3 → p2
    elif can_move(p3_0, p2_0) and last_move != ("p2", "p3"):
        do_move(p3_0, p2_0, "p3", "p2")

    else:
        print("No valid moves (stuck)")
        break

    print("p1:", p1_0)
    print("p2:", p2_0)
    print("p3:", p3_0)
    print("last:", last_move)
    print("-----")
    time.sleep(0.5)
