# SpectralPainting
This page is dedicated to providing files and instructions related to creating spectrogram "spectral paintings" using open-source tools. It will accompany a Youtube video (link TBD) that will walk the user through the theory behind how "spectral painting" works. This will provide similar functionality as [gr-paint](https://github.com/drmpeg/gr-paint), but only uses common blocks in Gnu Radio Companion.

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

Gimp allows for resizing the image, flipping vertically, converting to grayscale, and exporting in a format that Gnu Radio can directly import. Open Gimp and perform whichever of the following steps are necessary:

   - OPTIONAL: Resize the image. Image -> Scale Image -> adjust the needed sizes (width, height, or a combination of the two) -> Click on the "Scale" button.
   - MANDATORY: Convert to grayscale. Image -> Mode -> Grayscale.
   - OPTIONAL: Flip the image vertically. Image -> Transform -> Flip Vertically.
   - MANDATORY: Export the image as a ".raw" file. File -> Export As... -> Enter a filename and ensure that it has the extension .raw. When you click "Export", a popup window will appear. Leave the defaults and click on "Export" again to save the file.

The ".raw" file created by Gimp can be imported directly into the Gnu Radio Companion flowgraph "image2spectrum.grc" to create the spectral painting.

# Use Gnu Radio Companion to create the spectral painting



## Scale Amplitudes, Convert to Black-and-White, and Output as Floating-Point Values

The image will need to be imported into Gnu Radio Companion. While this program is awesome and has many capabilities, it does **not** have the ability to read in images. Instead, we'll use Gnu Octave to:
   - read in the file
   - convert to black-and-white (if its originally a color image)
   - scale the amplitudes so that, when displayed on the logarithmic scale of a spectral display, they'll be seen as linear
   - output the image as a single vector of real, 32-bit floating point values
     
To process with the Gnu Octave script:

   - put both the script and the image in the same directory.
   - Open Gnu Octave and, if necessary, change the working directory to that where the script and image are located.
   - On the Gnu Octave command line, run the script: **grcImage**
   - When prompted, enter the name of the file.
   - Gnu Octave will process the image and output the name of the real, 32-bit floating point file containing the samples ready for processing with Gnu Radio Companion.
   - EX (from the Gnu Octave command line):

    
      
## Process the Image Using Gnu Radio Companion

There are two Gnu Radio Companion (GRC) flowgraphs provided here. One will output the image as a complex .wav file. This file can be imported into several, different SDR programs, including SDR++, SDRangel, and SDRconnect. The other will allow for transmission using a transmit-capable SDR, such as a HackRF One or HackRF Pro, an Adalm Pluto, an Ettus Research USRP, or a BladeRF.

### Store as a .WAV File

![Gnu Radio Companion flowgraph designed to take in a file of real, 32-bit floating point numbers ("floats") and turn them into spectral data that will be output as a complex samples stored in a .WAV file.](https://github.com/JesterNoFool/SpectralPainting/blob/main/spectrum_painter_wav_flowgraph.jpg)

Open Gnu Radio Companion, then open the file **spectrum_painter_wav.grc**.
* In the variable entitled, "imageWidth", change the value to the width of the image that will be processed. NOTE: This value will be in the output filename if you used the Gnu Octave script above.
* In the variable entitled, "repeatVal", select a repeating value for each line. This accounts for the speed of the system that you will use to process the image. Those that have faster processing will require smaller values (say 5), while slower ones will require larger values (say 20).
* In the File Source, select the 32-bit floating point file (if you used the Gnu Octave script above, the file will have the extension ".rf32").
* In the Wav File Sink, provide a directory and name for the output file.
* **ENSURE THE "REPEAT" PROPERTY IN THE "File Source" BLOCK IS SET TO "No"!** Otherwise, the system will create a massive output file!

When you run this flowgraph, it will only run until it reaches the end of the file. As it is not throttled, the system may throw a warning (which can be ignored) and quickly finish. Once done (the various displays will freeze), you can close the running flowgraph. The file will have been created. You can now import that .WAV file into any program that accepts such files, such as SDRangel, SDRconnect and SDR++, examples of which are shown below.

![Spectrogram painting in SDRangel of the Lucerne image from above.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-Reuss-River-5rpt-SDRangel-8192pt-BH-window.png)

![Spectrogram painting in SDRconnect of the Lucerne image from above.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-River-Reuss-SDRconnect-8192pt-Sin5-window-BlackWhite-palette.png)

![Spectrogram painting in SDR++ of the Lucerne image from above.](https://github.com/JesterNoFool/SpectralPainting/blob/main/Lucerne-Reuss-River-20rpt-SDRpp-spectrogram-8192pt-Nuttall-window.png)

### Transmit using a SDR

![Gnu Radio Companion flowgraph outputting the complex samples to a SDR.](https://github.com/JesterNoFool/SpectralPainting/blob/main/spectrum_painter_usrp_flowgraph.jpg)

This example flowgraph uses a Ettus Research USRP B200mini to transmit the complex samples. This can be changed to another SDR by replacing this block with the appropriate block of the SDR being used, such as a HackRF One or HackRF Pro, a BladeRF, or an Adalm-Pluto.

Open Gnu Radio Companion, then open the file **spectrum_painter_usrp.grc**
* In the variable entitled, "samp_rate", adjust the output sample rate if its needed to either increase or decrease the bandwidth of the signal.
* In the variable entitled, "imageWidth", change the value to the width of the image that will be processed. NOTE: This value will be in the output filename if you used the Gnu Octave script above.
* In the variable entitled, "repeatVal", select a repeating value for each line. This accounts for the speed of the system that you will use to process the image. Those that have faster processing will require smaller values (say 5), while slower ones will require larger values (say 20). This can be changed at runtime, so is not crucial initially.
* In the File Source, select the 32-bit floating point file (if you used the Gnu Octave script above, the file will have the extension ".rf32").

When the flowgraph is running, one of the displays will be a time display showing the magnitude of the complex samples. These values should be less than 1 in order to not overdrive the transmit SDR. Use the "Output Gain (dB)" value to adjust this value. If the values in the time domain are going past the top of the display (greater than 1), then lower the "Output Gain" value until the values are less than 1.
