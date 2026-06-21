# Fixed-Point-Image-Scaling-Engine
Verilog implementation of a parameterized image scaling engine for the I-Chip'26 (Udyam) challenge. Implements bilinear interpolation using 8-bit fixed-point arithmetic, strictly avoiding floating-point units. Supports RGB/Grayscale formats with an architecture optimized for high PSNR/SSIM.
---

## Image Scaling Results

### Upscaling (256 × 256 → 512 × 512)

| Input | Output |
|:------:|:------:|
| <img src="images/input_256x256.png" width="300"/> | <img src="images/output_512x512.png" width="300"/> |

---

### Downscaling (512 × 512 → 128 × 128)

| Input | Output |
|:------:|:------:|
| <img src="images/input_512x512.png" width="300"/> | <img src="images/output_128x128.png" width="300"/> |
