[x,y] = ginput(2);
trigger(vid);
while ~islogging(vid)
    %wait
end
data = getdata(vid);
image = data(:,:,1,1);
image = data(y(1):y(2), x(1):x(2));
