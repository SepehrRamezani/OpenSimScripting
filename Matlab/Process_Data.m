% Add btk library to MATLAB path  -> https://code.google.com/archive/p/b-tk/downloads
clear all
folder = 'C:\MyCloud\GitHub\OpenSimScripting\Matlab\Data\Gait2354_Simbody\';
fname = 'Hip_Kinetic_SLOW_Crop.c3d';
q=1;
%% C3D file reading 
data = c3d_getdata([folder fname]);
%% Generate .Trc for Marker set
%%% Giving marker names 
Markerset=fieldnames(data.marker_data.Markers);
%%% Or any new lables. So you can change your lable based on your model. Make sure they are in the same order of C3d file marker's lable %%%
% Newmarkerlable={'LASI','RASI','LPSI','RPSI','LKNE','LTHI','LANK','LTIB','LTOE','LHEE','RKNE','RTHI','RANK','RTIB','RTOE','RHEE'};
%%% To convert C3D Vicon of REAL LAb axis to Opensim Axis XYZ -> ZXY 
MarkerData=data.marker_data.Time;
for i = 1:length(Markerset)
   MarkerData = [MarkerData data.marker_data.Markers.(Markerset{i})(:,3) data.marker_data.Markers.(Markerset{i})(:,1) data.marker_data.Markers.(Markerset{i})(:,2)];
end
generate_Marker_Trc(Markerset,MarkerData,data.marker_data.Info);
%% Generate GRF 
if strcmp(data.fp_data.Info(1).units.Moment_Mx1,'Nmm')
    p_sc = 1000;
%     data.fp_data.Info(:).units.Moment_Mx1 = 'Nm';
else
    p_sc = 1;
end
%%%  reoder data so Opensim Axis XYZ -> ZXY 
for i = 1:length(data.fp_data.FP_data)
   data.fp_data.GRF_data(i).P =  [data.fp_data.GRF_data(i).P(:,3) data.fp_data.GRF_data(i).P(:,1) data.fp_data.GRF_data(i).P(:,2)]/p_sc;
   data.fp_data.GRF_data(i).F =  [data.fp_data.GRF_data(i).F(:,3) data.fp_data.GRF_data(i).F(:,1) data.fp_data.GRF_data(i).F(:,2)];
   data.fp_data.GRF_data(i).M =  [data.fp_data.GRF_data(i).M(:,3) data.fp_data.GRF_data(i).M(:,1) data.fp_data.GRF_data(i).M(:,2)]/p_sc;
end
data.fp_data.GRF_data.Time= data.fp_data.Time; 
   
generate_GRF_Mot(data.fp_data.GRF_data,data.fp_data.Info)

