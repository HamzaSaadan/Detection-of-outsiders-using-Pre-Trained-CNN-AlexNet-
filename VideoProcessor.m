obj = VideoReader('C:\Users\hamza\Documents\MATALB PROJECT\Low Feed.mp4'); 
vid = read(obj); 

%frame extraction
for img = 1:obj.NumberOfFrames;
    filename = strcat('frame',num2str(img),'.jpg');
    b = read(obj, img);

    %frames to double precision
    doubleFrame = im2double(b);
    grayImg = im2gray(doubleFrame);
    

    %noise reduction
    noisyFrame = imnoise(grayImg,'salt & pepper',0.02);
    Kmedian = medfilt2(noisyFrame);
   
    imwrite(Kmedian,filename);

end