import random
import time

list_w = ["0", "X", "0", "X", "0", "X", "0", "X"]
list_obj = ["0", "0", "0", "0", "X", "X", "X", "X"]

i_random = random.randint(2, 5)
dir_random = random.randint(0, 1)

while list_w != list_obj:

    print("i:", i_random, "dir:", dir_random)
    
    before = list_w.copy()  # 🔹 track previous state

    if dir_random == 0 and i_random <= 5:

        list_w[i_random+2], list_w[i_random+1], list_w[i_random] = \
        list_w[i_random + 1], list_w[i_random], list_w[i_random + 2]

    elif dir_random == 1 and i_random >= 2:

        list_w[i_random-2], list_w[i_random-1], list_w[i_random] = \
        list_w[i_random - 1], list_w[i_random], list_w[i_random - 2]

    # 🔴 Check if anything changed
    if list_w == before:
        print("No change!")

    print(list_w)
    print("-----")

    # 🔹 always update randomness at the end
    i_random = random.randint(2, 5)
    dir_random = random.randint(0, 1)

    time.sleep(0.5)