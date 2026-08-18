# 2.45 GHz Microstrip Patch Antenna Design Report

## 1. Abstract
This report presents the analytical design, electromagnetic simulation, and optimization results of a rectangular microstrip patch antenna designed on an FR-4 substrate operating at a center frequency of 2.45 GHz.

## 2. Project Objective
The objective is to design a 50-ohm matched patch antenna radiating at 2.45 GHz for use in Wi-Fi, Bluetooth, and ISM applications, and to analyze its performance using the MATLAB Antenna Toolbox.

## 3. Working Principle and Design Equations
Patch antennas radiate through the fringing fields between the ground plane and the conductive patch. The transmission line model was used to calculate the antenna width (W) and length (L). The physical length was corrected by accounting for the effective dielectric constant and fringing length extensions.

## 4. Parameters and Results Summary

| Parameter | Value |
|---|---|
| Analytical Patch Length (mm) | 28.8093 |
| Optimized Patch Length (mm) | 26.8977 |
| Analytical Patch Width (mm) | 37.2343 |
| Optimized Patch Width (mm) | 36.9505 |
| Feed Offset (mm) | 7.2023 |
| Resonance Frequency (GHz) | 2.455 |
| S11 at 2.45 GHz (dB) | -26.3326 |
| Minimum S11 (dB) | -27.5917 |
| VSWR at Resonance | 1.0871 |
| Lower Cutoff Freq (GHz) | 2.3938 |
| Upper Cutoff Freq (GHz) | 2.518 |
| Bandwidth (MHz) | 124.1738 |
| Fractional Bandwidth (%) | 5.0561 |
| Max Gain (dBi) | 4.1265 |
| Radiation Efficiency | 0.7309 |

## 5. Interpretation of Simulation Results
### S11 and Impedance Matching
Following optimization, the antenna's resonance frequency was successfully tuned to the 2.45 GHz target. The S11 plot demonstrates that power reflection is minimized at the target frequency, indicating that the majority of the energy is radiated.

![S11 Plot](../results/optimized_s11.png)

### Manufacturing Tolerances and FR-4 Losses
Due to the high loss tangent (0.02) of the FR-4 substrate, the antenna efficiency may be relatively low. Furthermore, fluctuations in the dielectric constant of FR-4 can cause shifts in the resonance frequency. Therefore, minor dimensional adjustments (tuning) might be required post-manufacturing.

## 6. Conclusion
The design, simulation, and optimization steps have been successfully completed, yielding a suitable microstrip patch antenna for the 2.45 GHz ISM band.
