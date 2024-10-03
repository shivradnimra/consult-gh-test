import numpy as np
import matplotlib.pyplot as plt

plt.style.use("bosch")
x = np.linspace(0, 2 * np.pi, 100)
y = np.sin(x)
plt.plot(x, y)

x = np.linspace(0, 2 * np.pi, 1000)
y = np.sin(x) + np.cos(10 * x) + np.random.random(len(x))
plt.plot(x, y)

plt.xlabel("time")
plt.ylabel("data")
plt.show()
