Just run 'run_panorama_demo.m' to get a testing 360 panorama iamge. And you
can modify this file to get other 360 panorama images.

If you want panorama iamges added by your own, you should do:
1: add these images to a subdirectory of './data', adn name it as 
   'imagesID' (ID is up to you), then find the line 'imagesID = 1' in 
   'run_panorama_demo.m', and modify it to 'imagesID = ID', so algorithm 
   can read these images.
2: you should have the knolewdge of the sensor size (Wccd) of your camera, 
   then open 'cylinder_projection.m', find the line 'elseif imagesID == 3',
   and add another 'elseif' statement as the above.
3: if you have done correctly befor, then run 'run_panorama_demo.m', and
   you should get a 360 panorama.

Written by Qiankun Liu in Nov. 2017.
