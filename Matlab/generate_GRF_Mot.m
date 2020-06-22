function generate_GRF_Mot(data ,Info)


% F = data.fp_data.Info(1).frequency/data.marker_data.Info.frequency; % assume that all force plates are collected at the same frequency!!!

fp_time = Info.Time;

% initialise force data matrix with the time array and column header
force_data_out = fp_time';
force_header = 'time';
force_format = '%20.6f\t';

% go through each marker field and re-order from X Y Z to Y Z X and place
% into data array and add data to the force data matrix --> also need to
% divide by 1000 to convert to mm from m if necessary and Nmm to Nm 
% these are the conversions usually used in most motion analysis systems
% and if they are different, just change the scale factor below to p_sc 
% value for the M data to 1. It should however get this from the file.
   
for i = 1:length(data.fp_data.FP_data)
    
    % reoder data so lab coordinate system to match that of the OpenSim
    % system

   % do some cleaning of the COP before and after contact

   
   % define the period which we are analysing
%    K = (F*data.Start_Frame):1:(F*data.End_Frame);
      
   % add the force, COP and moment data for current plate to the force matrix 
   force_data_out = [force_data_out data.fp_data.GRF_data(i).F(K,:) data.fp_data.GRF_data(i).P(K,:) data.fp_data.GRF_data(i).M(K,:)];
   % define the header and formats
   force_header = [force_header [num2str(i)+"_ground_force_vx" ] [num2str(i)+"_ground_force_vy" ] [num2str(i)+"_ground_force_vz"]...
                  [num2str(i)+"_ground_force_px" ] [num2str(i)+"_ground_force_py" ] [num2str(i)+"_ground_force_pz" ...
       ] [num2str(i)+"_ground_torque_x" ] [num2str(i)+"_ground_torque_y" ] [num2str(i)+"_ground_torque_z"]];
   force_format = [force_format '%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t'];
   
end



% assign a value of zero to any NaNs
force_data_out(logical(isnan(force_data_out))) = 0;



fid_2 = fopen([pname newfilename],'w');

write the header information
fprintf(fid_2,'name %s\n',newfilename);
fprintf(fid_2,'datacolumns %d\n', size(force_data_out,2));  % total # of datacolumns
fprintf(fid_2,'datarows %d\n',length(fp_time)); % number of datarows
fprintf(fid_2,'range %f %f\n',fp_time(1),fp_time(end)); % range of time data
fprintf(fid_2,'endheader\n');
fprintf(fid_2,force_header);

% write the data
fprintf(fid_2,force_format,force_data_out');

fclose(fid_2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

