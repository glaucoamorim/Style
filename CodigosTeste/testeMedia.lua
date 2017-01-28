media = {[1] = {_attr={id="video1",layout="mVideos#videos",src="video.mp4",xlabel="video"}}, [2] = {_attr={id="video2",layout="mVideos#videos",src="video2.mp4",xlabel="video"}}, [3] = {_attr={id="video3",layout="mVideos#videos",src="video3.mp4",xlabel="video"}}}

for k,v in ipairs(media) do
  print(k, v._attr.id)
end