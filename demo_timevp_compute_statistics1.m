
%% compute basic statistics 
clear; 
addpath('timevp_lib')
 
%% 
subject_list = [7002 7003  7005 7006 7008]; 
variable_name = 'cevent_eye_roi_child';
output_file = 'compute_stats1.csv'; 

%%
result = timevp_compute_statistics(variable_name, subject_list); 
result = rmfield(result,{'data_list', 'individual_trans_matrix'});
struct2csv(result,output_file); 
