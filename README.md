# Fixed-Point-Image-Scaling-Engine
Verilog implementation of a parameterized image scaling engine for the I-Chip'26 (Udyam) challenge. Implements bilinear interpolation using 8-bit fixed-point arithmetic, strictly avoiding floating-point units. Supports RGB/Grayscale formats with an architecture optimized for high PSNR/SSIM.


## Image Scaling Results

### Upscaling Result 1 : 800 × 525 → 1600 × 1050

<p align="center">
  <img src="images%20resized/up_sc_1.jpg" width="800">
</p>

*Input (left) and scaled output (right).*

---

### Upscaling Result 2 : 500 × 375 → 1000 × 750

<p align="center">
  <img src="images%20resized/up_sc_2.jpgg" width="800">
</p>

*Input (left) and scaled output (right).*

---

### Downscaling Result 1 : 800 × 525 → 400 × 200

<p align="center">
  <img src="images%20resized/dw_sc_1.jpg" width="800">
</p>

*Input (left) and scaled output (right).*

---

### Downscaling Result 2 : 500 × 375 → 250 × 250

<p align="center">
  <img src="images%20resized/dw_sc_2.jpg" width="800">
</p>

*Input (left) and scaled output (right).*
