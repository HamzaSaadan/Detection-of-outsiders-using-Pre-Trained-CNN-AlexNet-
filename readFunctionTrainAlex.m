function[b] = readFunctionTrainAlex(allImages)

a = imread(allImages);
a = imresize(a, [227 227]);
b=a
[r c p] = size (a);
if p<3
    b(:, :, 1)=a;
        b(:, :, 2)=a;
            b(:, :, 3)=a;
end
end

