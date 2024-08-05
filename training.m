% clc
% clear all
% close all
% warning off

%data store
imds = imageDatastore('C:\Users\hamza\Documents\MATALB PROJECT\transfer\dataset2', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');
%image input size
inputSize = [227 227 3];

%data augmentation
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...
    'RandXTranslation', [-30 30], ...
    'RandYTranslation', [-30 30], ...
    'RandRotation', [-30 30]);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

%training options
options = trainingOptions('sgdm', ...
    'Plots', 'training-progress', ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.2, ...
    'LearnRateDropPeriod', 5, ...
    'MiniBatchSize', 400, ...
    'MaxEpochs', 10, ...
    'InitialLearnRate', 0.001, ...
    'ValidationFrequency', 3, ...
    'L2Regularization', 0.001, ...
    'ValidationData',augimdsValidation, ...
    'Plots','training-progress');

% k-fold cross-validation
numFolds = 5;
cvAccuracy = zeros(1, numFolds);


for fold = 1:numFolds
    [imdsTrain, imdsValidation] = splitEachLabel(imds, 0.7, 'randomized');
    
    % Define AlexNet
    g = alexnet;

    % Modify layers
    No_of_class = numel(categories(imds.Labels));
    Layers = g.Layers;
    Layers(23) = fullyConnectedLayer(No_of_class);
    Layers(25) = softmaxLayer;
    Layers = [
        Layers
        batchNormalizationLayer
        fullyConnectedLayer(No_of_class)
        %dropoutLayer(0.5)
        %batchNormalizationLayer
        fullyConnectedLayer(No_of_class)
        dropoutLayer(0.6)
        softmaxLayer
        classificationLayer
    ];

    % Set up image data augmentation
    augimdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, 'DataAugmentation', imageAugmenter);

    % Train network
    net2 = trainNetwork(augimdsTrain, Layers, options);
    save net2;

    % Evaluate the model
    [YPred, scores] = classify(net2, imdsValidation);
    YValidation = imdsValidation.Labels;
    cvAccuracy(fold) = mean(YPred == YValidation);
    
    disp(['Fold ', num2str(fold), ' Accuracy: ', num2str(cvAccuracy(fold))]);
end

% Average cross-validation accuracy
averageAccuracy = mean(cvAccuracy);
disp(['Average Cross-Validation Accuracy: ', num2str(averageAccuracy)]);
[Pred,scores] = classify(net,augimdsValidation);
YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);
