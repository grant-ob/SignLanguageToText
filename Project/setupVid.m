vid = videoinput('winvideo',2,'YUY2_720x480');
triggerconfig(vid, 'Manual');
set(vid, 'LoggingMode', 'memory');
set(vid,'TriggerRepeat',Inf)
set(vid, 'FramesPerTrigger', 10);
set(vid, 'FrameGrabInterval', 5);
vidRes = get(vid, 'VideoResolution');
nBands = get(vid, 'NumberOfBands');
hImage = image(zeros(vidRes(2), vidRes(1), nBands));
current_letter = 1;
preview(vid, hImage);
start(vid);