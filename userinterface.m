function userinterface


if ~exist('webcam', 'file')
    msgbox('Error: Webcam not detected.', 'Error', 'error');
    return;
end

Webcam = webcam;
load net;
video_Player = vision.VideoPlayer();

face_Detector = vision.CascadeObjectDetector();
point_Tracker = vision.PointTracker('MaxBidirectionalError', 2);
is_tracking = false; % Initialize tracking flag

run_loop = true;
frame_Count = 0;

while isvalid(video_Player) && run_loop && frame_Count < 4000000
    video_Frame = snapshot(Webcam);
    gray_Frame = rgb2gray(video_Frame);
    frame_Count = frame_Count + 1;

    % Face detection
    bboxes = step(face_Detector, video_Frame);
    if ~isempty(bboxes)
        % Track the face if detected
        if ~is_tracking
            points = detectMinEigenFeatures(gray_Frame, 'ROI', bboxes(1, :));
            xy_Points = points.Location;
            number_of_Points = size(xy_Points, 1);

            if number_of_Points >= 10
                release(point_Tracker);
                initialize(point_Tracker, xy_Points, gray_Frame);
                is_tracking = true;
                old_Points = xy_Points;
            end
        else
            [xy_Points, isFound] = step(point_Tracker, gray_Frame);
            new_Points = xy_Points(isFound, :);
            old_Points = old_Points(isFound, :);

            number_of_Points = size(new_Points, 1);

            if number_of_Points >= 10
                [xform, old_Points, new_Points] = estimateGeometricTransform(old_Points, new_Points, 'similarity', 'MaxDistance', 4);
                rectangle = bbox2points(bboxes(1, :));
                face_Polygon = reshape(rectangle', 1, []);
                video_Frame = insertShape(video_Frame, 'Polygon', face_Polygon, 'LineWidth', 3);
                video_Frame = insertMarker(video_Frame, new_Points, "+", 'Color', 'white');
                setPoints(point_Tracker, old_Points);
            else
                is_tracking = false;
            end
        end

        % Crop the face region and classify
        es = imcrop(video_Frame, bboxes(1, :));
        es = imresize(es, [227 227]);
        [label, scores] = classify(net, es);
        confidence = max(scores); % Maximum confidence score
        if confidence >= 0.7
            title_label = ['Tracking: ', char(label), ' (Confidence: ', num2str(confidence), ')'];
        else
            title_label = 'Outsider';
            msg = 'Warning: Outsider Detected!';
            showWarningMessageBox(msg);
        end
    else
        % Stop tracking if no face detected
        is_tracking = false;
        title_label = 'No Face Detected';
    end

    % frame with title
    imshow(video_Frame, 'Parent', app.UIAxes);
    title(app.UIAxes, title_label);
    drawnow;

    run_loop = isvalid(video_Player) && isvalid(app.UIFigure) && ishandle(app.UIAxes) && isequal(get(app.UIAxes,'type'),'axes');
end

% Clean up
clear Webcam;
release(video_Player);
release(point_Tracker);
release(face_Detector);

end

function showWarningMessageBox(msg)
    h = msgbox(msg, 'Warning', 'warn');
    set(h, 'position', [500, 500, 250, 75]); % Position the message box
end