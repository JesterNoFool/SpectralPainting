# SpectralPainting
Files related to creating spectrogram "spectral paintings" using Gimp, Gnu Octave and Gnu Radio Companion.

![Spectrogram painting of Renoir's "Le Pont-Neuf", painted originally in 1872.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Renoir-Le-Pont-Neuf-spectrogram-16384pt-Nuttall-window.png)

# General Steps

The general steps for creating a "spectral painting", assuming you have an image file (.jpg, .tif, .webp, .png) is as follows:
1. Use Gimp to resize (rescale) the image and, if necessary, flip the image top to bottom. You'll need to flip the image if the spectrogram is a falling raster (scrolls downward).
2. Use Gnu Octave to convert the image file into a file of real-only 32-bit floating point numbers (.rf32).
3. Use Gnu Radio Companion to:
  _ randomize the phase of each frequency point (bin)
  _ calculate the inverse FFT (convert from frequency domain to time domain) of each line
  _ output the complex samples to a file or SDR for transmission
