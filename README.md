# SpectralPainting
Files and instructions related to creating spectrogram "spectral paintings" using open-source tools.

![Spectrogram painting of Renoir's "Le Pont-Neuf", painted originally in 1872.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Renoir-Le-Pont-Neuf-spectrogram-16384pt-Nuttall-window.png)

# General Steps

The general steps for creating a "spectral painting", assuming you have an image file (.jpg, .tif, .webp, .png) is as follows:
1. Resize and (if necessary) flip the image. NOTE: Flipping is typically needed if the spectrogram on which the image will be displayed is a falling waterfall; otherwise, the picture will be upside-down:
   - Imagemagick: From the command line, "convert inputfile.jpg -resize 1600x outputfile.jpg"
   - ffmpeg: From the command line, "ffmpeg -i inputfile.jpg -filter:v "vflip, scale=1600:-1" outputfile.jpg"
   - Gimp: Import the image, scale the image (Image -> Scale Image), and flip (if necessary, Image -> Transform -> Flip Vertically).
3. Use script Gnu Octave above to:
   - rescale each amplitude so that, when converted to dB, they'll be linear values
   - convert the image file into a file of real-only 32-bit floating point numbers (.rf32).
4. Use the Gnu Radio Companion flowgraph to:
   - randomize the phase of each frequency point (bin)
   - calculate the inverse FFT (convert from frequency domain to time domain) of each line
   - output the complex samples to a file or SDR for transmission

# Example

We'll use this image taken in Lucerne, Switzerland, to demonstrate how to create a "spectrogram painting". 

![Image showing a narrow river with buildings on either side. A church is on the right bank in the background, and the sky is blue with some fluffy clouds visible.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-Reuss-river.jpg)

## Resizing and Flipping

The original image is 5312 pixels wide x 2988 pixels high. While this will *work*, it's probably a lot larger image than is needed, even for a decent image. Further, we're going to test it on SDR++. SDR++ uses a falling waterfall. This means we'll need to flip the image (unless you enjoy looking at images upside-down). There are several ways to accomplish these tasks. We'll cover three, different methods:
   - Use imagemagick. If you have imagemagick installed on your system, you can use a command line statement to perform both the resizing and the image flip. In the command line, navigate to the directory containing the image and use the following command to set the image to a 1600 pixel width, have the system automatically set the height to maintain the same aspect ratio, and flip the image: **convert inputfile.jpg -resize 1600x outputfile.jpg** 
