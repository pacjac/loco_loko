// CLEAR PATH
clear();
clearglobal();
// LOAD Functions
//cd('/Users/felix/Documents/Studium/Master/Sem3/Loko/losCorredors/src/')
absolute_path = get_absolute_file_path('scale_experiment.sce')
getd(absolute_path);

// get path to the offset measurement file:
absolute_path = get_absolute_file_path('scale_experiment.sce')
file = uigetfile();
offsetDataRaw = fscanfMat(file);

// FORMATTING OF THE FILE:
//Channel
//1 x1+x2
//2 x3+x4
//3 y1+y4
//4 y2+y3
//5:8 z1:z4

// combine the channels into a global data structure
offsetData(:,1) = offsetDataRaw(:,1);
offsetData(:,2) = offsetDataRaw(:,2) + offsetDataRaw(:,3);
offsetData(:,3) = offsetDataRaw(:,4) + offsetDataRaw(:,5);
offsetData(:,4) = offsetDataRaw(:,6) + offsetDataRaw(:,7) + offsetDataRaw(:,8) + offsetDataRaw(:,9);

// calculate linear regression of the scale
[ scaleOffsetSLOPE, scaleOffsetYOFFSET, scaleOffsetSIGMA ]= reglin( offsetData(:,1)', offsetData(:,2)' );

// add labels n stuff to the plot and save it!
plot(offsetData(:,1),[offsetData(:,2) scaleOffsetSLOPE * offsetData(:,1) + scaleOffsetYOFFSET])
