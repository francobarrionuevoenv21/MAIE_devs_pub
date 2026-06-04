import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("prof1DDataOut/profData.txt")

x = data[:,0]
T = data[:,1]

fig, ax = plt.subplots(figsize=(8, 6))
ax.plot(x, T)
ax.set_xlabel("Index")
ax.set_ylabel("Temperature (K)")
ax.set_title("Temperature Profile")
plt.show()