clear();
clearglobal;

video_path = uigetfile("*.*","","Select Video data",%t);

drop = uigetdir();

for i = 1:size(video_path, 2)
    unix_s("mkdir -p " + drop + "/" + string(i) )
    unix_s("/usr/local/Cellar/ffmpeg/3.2/bin/ffmpeg -i " + video_path(i) + " -r 50 -s 853x479 -aspect 853:479 -qscale 1 " + drop + "/" + string(i) + "/image%04d.png") // + "/" + string(i)
end
