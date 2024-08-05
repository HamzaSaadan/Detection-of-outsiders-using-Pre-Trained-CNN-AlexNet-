function results = myimfcn(varargin)
%Image Processing Function
%
% VARARGIN - Can contain up to two inputs: 
%   IM - First input is a numeric array containing the image data. 
%   INFO - Second input is a scalar structure containing information about 
%          the input image source.
%
%   INFO can be used to obtain metadata about the image read. 
%   To apply a batch function using the INFO argument, you must select the 
%   Include Image Info check box in the app toolstrip.
%   
% RESULTS - A scalar struct with the processing results.
%
% 
%
%--------------------------------------------------------------------------
% Auto-generated by imageBatchProcessor App. 
%
% When used by the App, this function will be called for each input image
% file automatically.
%
%--------------------------------------------------------------------------

% Input parsing------------------------------------------------------------
im = varargin{1};

if nargin == 2
    % Obtain information about the input image source
    info = varargin{2};
end

% Replace the sample below with your code----------------------------------

resize = imresize(im, [227 227]);

% Get dimensions
[rows, columns, numberOfColorBands] = size(resize);

%gray scale
%imgray = im2gray(resize);


%noise reduction
noisyFrame = imnoise(resize,'salt & pepper',0.02);

% Extracting individual red, green, and blue color channels.
redChannel = noisyFrame(:, :, 1);
greenChannel = noisyFrame(:, :, 2);
blueChannel = noisyFrame(:, :, 3);

%noise removal
redMF = medfilt2(redChannel, [3 3]);
greenMF = medfilt2(greenChannel, [3 3]);
blueMF = medfilt2(blueChannel, [3 3]);

% Find the noise in the red.
noiseImage = (redChannel == 0 | redChannel == 255);
noiseFreeRed = redChannel;
noiseFreeRed(noiseImage) = redMF(noiseImage);

% Find the noise in the green.
noiseImage = (greenChannel == 0 | greenChannel == 255);
noiseFreeGreen = greenChannel;
noiseFreeGreen(noiseImage) = greenMF(noiseImage);

% Find the noise in the blue.
noiseImage = (blueChannel == 0 | blueChannel == 255);
noiseFreeBlue = blueChannel;
noiseFreeBlue(noiseImage) = blueMF(noiseImage);

%Rejoin
rgbFixed = cat(3, noiseFreeRed, noiseFreeGreen, noiseFreeBlue);

results.imgray = rgbFixed;

%--------------------------------------------------------------------------
