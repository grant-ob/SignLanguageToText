start(vid);
trigger(vid);
wait(vid);
data = getdata(vid);
% training_images(current_letter, 1) = data(:,:,1,1);
% training_images(current_letter, 2) = data(:,:,1,10);
current_letter = current_letter + 1;
