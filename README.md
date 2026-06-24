# SpectralPainting
This page is dedicated to providing files and instructions related to creating spectrogram "spectral paintings" using open-source tools. It will accompany a Youtube video (link TBD) that will walk the user through the theory behind how "spectral painting" works. This will provide similar functionality as [gr-paint](https://github.com/drmpeg/gr-paint), but only uses common blocks in Gnu Radio Companion, as well as some other open source tools.

![Spectrogram painting of Renoir's "Le Pont-Neuf", painted originally in 1872.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Renoir-Le-Pont-Neuf-spectrogram-16384pt-Nuttall-window.png)

# General Steps

The general steps for creating a "spectral painting", assuming you have an image file (.jpg, .tif, .webp, .png) is as follows:
1. Resize and (if necessary) flip the image. NOTE: Flipping is typically needed if the spectrogram on which the image will be displayed is a falling waterfall; otherwise, the picture will be upside-down:
   - Imagemagick: From the command line, "convert inputfile.jpg -resize 1600x -flip outputfile.jpg"
   - ffmpeg: From the command line, "ffmpeg -i inputfile.jpg -filter:v "vflip, scale=1600:-1" outputfile.jpg"
   - Gimp: Import the image, scale the image (Image -> Scale Image), and flip (if necessary, Image -> Transform -> Flip Vertically).
2. Transform the image into a grayscale and export it as a straight "raw" file (8-bit unsigned integers) that can be imported directly into Gnu Radio Companion. The methods to do this are:
   - Use Gimp to both convert to grayscale (Image -> Mode -> Grayscale). Then export as a ".raw" file (File -> Export As... -> Change the extension on the filename to ".raw").
   - Use either of the Gnu Octave scripts provided (grcImage or grcImageFlip) to both convert to grayscale and export as 8-bit unsigned integers (adds a ".ru8" extension).
3. Use the Gnu Radio Companion flowgraph to:
   - adjust (pre-distort) the amplitudes that, when displayed on the log scale of a spectral display, the image values will effectively be linear.
   - randomize the phase of each frequency point (bin)
   - calculate the inverse FFT (convert from frequency domain to time domain) of each line
   - output the complex samples to a file or SDR for transmission

# Example

We'll use this image taken in Lucerne, Switzerland, to demonstrate how to create a "spectrogram painting". 

![Image showing a narrow river with buildings on either side. A church is on the right bank in the background, and the sky is blue with some fluffy clouds visible.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-Reuss-river.jpg)

# Resize the image, convert to grayscale, flip vertically, convert to 8-bit unsigned integer format

The original image is 5312 pixels wide x 2988 pixels high. While this will *work*, it's probably a lot larger image than is needed, even for a decent image. For this example, let's say that we want to constrain the width to 1600 pixels. Further, we're going to test it on several SDR programs, all of which use a falling waterfall. This means we'll need to flip the image (unless you enjoy looking at images upside-down). There are several ways to accomplish these tasks.

## Using Imagemagick & Gnu Octave
 
   - Use imagemagick to resize and vertically flip the image. In the command line, navigate to the directory containing the image and use the following command to set the image to a 1600 pixel width, have the system automatically set the height to maintain the same aspect ratio, and flip the image: **convert inputfile.jpg -resize 1600x -flip outputfile.jpg**
   - Place the image created using imagemagick, and the Gnu Octave script "grcImage", into the Gnu Octave working directory. In Gnu Octave, run the script. It will ask for the filename. Type (or copy-and-paste) the filename. It will automatically convert the image to grayscale and output the image as a 1D array of values representing each line of the image. The values will be 8-bit unsigned integers (which is why the extension has been added as ".ru8").
   - NOTE: You can also use Imagemagick to just resize the image, then use the Gnu Octave script "grcImageFlip" to convert the image to grayscale, flip it vertically, and export it as the 8-bit unsigned integers.

  ```
      >>grcImage
     
      >>Enter the filename: Lucerne-Reuss-river-resized-flipped.jpg

      >>Successfully wrote file as Lucerne-Reuss-river-resized-flipped-1600pt-width.ru8
  ```

The ".ru8" file created by Gnu Octave can be imported directly into the Gnu Radio Companion flowgraph "image2spectrum.grc" to create the spectral painting.

## Using ffmpeg & Gnu Octave

   - Use ffmpeg to resize the image (and possible flip it vertically). As with imagemagick, ffmpeg can both resize and flip the image, all from one statement on the command line. Again from command line, navigate to the directory containing the image, then use the following command to resize to a width of 1600 pixels, automatically set the height to maintain the same aspect ratio, and flip the image: **ffmpeg -i inputfile.jpg -filter:v "vflip, scale=1600:-1" outputfile.jpg**
   - Place the image created using ffmpeg, and the Gnu Octave script "grcImage", into the Gnu Octave working directory. In Gnu Octave, run the script. It will ask for the filename. Type (or copy-and-paste) the filename. It will automatically convert the image to grayscale and output the image as a 1D array of values representing each line of the image. The values will be 8-bit unsigned integers (which is why the extension has been added as ".ru8").
   - NOTE: You can also use ffmpeg to just resize the image, then use the Gnu Octave script "grcImageFlip" to convert the image to grayscale, flip it vertically, and export it as the 8-bit unsigned integers.

The ".ru8" file created by Gnu Octave can be imported directly into the Gnu Radio Companion flowgraph "image2spectrum.grc" to create the spectral painting.

## Use Gimp

Gimp allows for everything needed to create a file that can be imported into Gnu Radio Companion. This includes resizing the image, flipping vertically, converting to grayscale, and exporting in a format that Gnu Radio can directly import. Open Gimp and perform whichever of the following steps are necessary:

   - OPTIONAL: Resize the image. Image -> Scale Image -> adjust the needed sizes (width, height, or a combination of the two) -> Click on the "Scale" button.
   - MANDATORY: Convert to grayscale. Image -> Mode -> Grayscale.
   - OPTIONAL: Flip the image vertically. Image -> Transform -> Flip Vertically.
   - MANDATORY: Export the image as a ".raw" file. File -> Export As... -> Enter a filename and ensure that it has the extension .raw. When you click "Export", a popup window will appear. Leave the defaults and click on "Export" again to save the file.

The ".raw" file created by Gimp can be imported directly into the Gnu Radio Companion flowgraph "image2spectrum.grc" to create the spectral painting.

# Use Gnu Radio Companion to create the spectral painting

![Gnu Radio Companion flowgraph "image2spectrum.grc"](https://github.com/JesterNoFool/SpectralPainting/blob/main/image2spectrum-flowgraph.jpg)

The provided Gnu Radio Companion flowgraph will:

   - read in the file
   - adjust the amplitudes (pre-warp) so that they are "linear" on the final spectrogram
   - randomize the phases of each frequency bin
   - set each line to be a power-of-2 length by zeropadding each end of a line. NOTE: This also centers the image in the spectral display.
   - repeat lines if needed by the receiving spectrogram. NOTE: This may be needed if the receiving spectrogram has a slow update rate. Otherwise, the image will be "squished" vertically.
   - calculate the inverse FFT (IFFT), which transforms the frequency domain amplitudes and phases of each image line into the time domain.
   - output to a file or SDR.

In Gnu Radio Companion, open the flowgraph "image2spectrum.grc".

   - In the File Source block, select the desired file (the .ru8 or .raw created above).
   - Set the image width manually by entering the width of the image, in pixels, in the "image_width" variable block.
   - If desired, adjust the output dynamic range (in dB) using the "dr" variable. The default is 40, but you may want to make this larger if you have a transmit SDR capable of handling more than 8 bits in the DAC.
   - If the file will be transmitted using a SDR:
   
       - connect the necessary SDR sink block (ex: Soapy HackRF Sink, osmocom Sink) to the output of the "Vector to Stream" block and delete or disable the "Throttle" block.
       - adjust the sample rate, if needed.
       - in the "File Source" block, set the "Repeat" value to "Yes".
       - run the flowgraph. If the image on the receive end is stretched vertically, lower the "Repeat" value and rerun the flowgraph. If it is squished (too short) vertically, raise the "Repeat" value and rerun.

   - If the file will be stored as a .WAV file:

      - Enable the "Complex to Float" and "WAV File Sink" blocks.
      - Enter the desired name in the "WAV File Sink" properties, ensuring that the extension ".wav" is on the end of the filename.
      - In the "File Source" block, ensure that the "Repeat" value is set to "No".
      - Run the flowgraph. The output ".wav" file can now be imported directly into one of several programs, including SDRconnect, SDR++, and SDRangel, as demonstrated below.

![Spectrogram painting in SDRangel of the Lucerne image from above.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-Reuss-River-5rpt-SDRangel-8192pt-BH-window.png)

![Spectrogram painting in SDRconnect of the Lucerne image from above.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-River-Reuss-SDRconnect-8192pt-Sin5-window-BlackWhite-palette.png)

![Spectrogram painting in SDR++ of the Lucerne image from above.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-Reuss-River-20rpt-SDRpp-spectrogram-8192pt-Nuttall-window.png)
