# Fortran Exercises for Atmospheric Modeling (CHIMERE Prep)

This set of exercises is designed to take you from basic Fortran syntax to building a simplified atmospheric model. Focus on understanding arrays, loops, subroutines, and memory management.

---

## 🟢 LEVEL 1 — Foundations

### 1. Temperature Conversion
- Ask the user for a temperature in Kelvin
- Convert it to Celsius
- Print the result

---

### 2. Power Calculator
- Ask the user for two numbers: `x` and `n`
- Compute x^n
- Print the result

---

### 3. Array Mean
- Create an array of 10 numbers
- Compute the mean manually (using a loop)

---

### 4. Max and Min
- Given an array of numbers
- Find the maximum and minimum values manually (no built-in functions)

---

## 🟡 LEVEL 2 — Arrays & Grids

### 5. 1D Temperature Profile
- Create an array of 50 elements
- Fill it with a linear gradient (e.g., from 300K to 280K)

---

### 6. 2D Constant Field
- Create a 50×50 grid
- Fill it with a constant value (e.g., pollutant concentration)

---

### 7. Gaussian Plume (1D)
- Create a 1D array
- Add a peak in the center
- Decrease values symmetrically away from the center

---

### 8. Time Decay
- Apply exponential decay:
  C = C * exp(-k * dt)
- Apply it to every element in an array

---

## 🔵 LEVEL 3 — Subroutines & Modularity

### 9. Decay Subroutine
- Move the decay logic into a subroutine:
  call decay(conc, k, dt)

---

### 10. Time Loop Simulation
- Create a loop over time steps
- Apply decay at each step

---

### 11. Add Emissions
- Add a constant emission source at the center of the grid
- Update values at each timestep

---

## 🔴 LEVEL 4 — Transport & Physics

### 12. 1D Advection
Implement:
C(i) = C(i) - u * (C(i) - C(i-1)) / dx

- Simulate movement of a pollutant plume

---

### 13. 2D Diffusion
- Update each grid cell using neighboring values
- Simulate spreading of pollution

---

### 14. Boundary Conditions
- Apply boundary rules:
  - Fixed value
  - Zero gradient
- Ensure your simulation remains stable

---

## 🟣 LEVEL 5 — Advanced Basics

### 15. Modular Code Structure
- Create modules:
  - module parameters
  - module physics
- Use public and private
- Call subroutines from main

---

### 16. Dynamic Allocation
- Ask user for grid size
- Allocate arrays dynamically
- Deallocate at the end

---

### 17. File Output
- Save your grid to a file
- Load it in Python and visualize it

---

### 18. Multi-Species Simulation
- Track at least two variables (e.g., O3 and NO2)
- Apply different decay rates

---

## 🧪 FINAL PROJECT

### 19. Mini Air Pollution Model

Build a simplified model with:

- 2D grid
- Emission source
- Advection (wind transport)
- Decay (chemistry)
- Time loop

---

## 🧠 Recommended Workflow

For each exercise:
1. Implement the solution
2. Add print statements to debug
3. Break it intentionally and fix it
4. Compare results with Python (if possible)

---

## ⚡ Best Practices

- Always use:
  implicit none

- Prefer explicit precision (real(dp))
- Use subroutines for repeated logic
- Print intermediate results for debugging

---

## 🎯 Goal

By completing these exercises, you should be able to:
- Understand Fortran scientific code
- Work with multidimensional arrays
- Build simulation loops
- Read and modify atmospheric models
