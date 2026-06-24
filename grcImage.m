% Import image and export as raw array for importing
% into Gnu Radio Companion. The image will be displayed
% on a spectrogram as a picture.
%
% Written by Gary Schafer, Signal Galaxies Unlimited, 2026
%
% To convert the image file to a real, 32-bit floating point file,
% move or copy the file into the same directory as this program,
% then run this program. Enter the name of the image file (including
% the extension) when prompted and press <Enter>. The program will
% read in the image file, convert to grayscale (if its color),and
% output the values to a file as 8-bit unsigned integer numbers
% (i.e. effectively convert the file from whatever format to a 
% "raw" format).

clear all;
close all;

% Input the filename
filename=input("Enter the filename: ","s");

% Read in image and determine width and height
myImage=double(imread(filename));
sz=size(myImage);
numLines=sz(1); % Image height
imWidth=sz(2);  % Image width

% If the image is color (which requires three layers), the
% following for-loop will convert it to a black-and-white
% image by averaging the three colors together.
                        
if(length(sz)==3)  % If there are three layers, then its color
    if(sz(3)==3)
        R=myImage(:,:,1);  % red layer
        G=myImage(:,:,2);  % green layer
        B=myImage(:,:,3);  % blue layer
        myImage=(R+G+B)/3;  % Average the three layers together
    endif
endif

% Create the final filename which will contain the prefix of the
% original file as well as the width of the final file.

% Start by figuring out the prefix (the part of the filename before
% the extension).
flen=length(filename); % Calculate length of filename
while(flen>0)
    ft=double(filename(flen)); % Calculate ASCII value of characters
                               % starting with last character and
                               % working backwards
    if(ft==46)      % If the character is a period (ASCII value = 46)
                    % then stop.
        break
    endif
    flen=flen-1;    % Didn't find the period yet, so keep going.
    
endwhile
if(flen==1)
    printf("There doesn't appear to be an extension to the file.\n");
    filenameOut="Imagefile";
else
    flen=flen-1; % Subtract the period from the filename
    filenameOut=filename(1:flen); % Pull out the filename prefix
endif

filenameOut=[filenameOut "-" num2str(imWidth) "pt-width.ru8"];

% Write the file out as real 32-bit floating point numbers (.rf32)

fid=fopen(filenameOut,"w");  % Open the file
for(ii=1:numLines)
    fwrite(fid,myImage(ii,:),'uint8');  % Loop through each line in order
endfor
fclose(fid);  % Close the file and done!
printf(["Successfully wrote file as " filenameOut "\n"]);
