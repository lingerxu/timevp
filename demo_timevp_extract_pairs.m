function demo_timevp_extract_pairs(demo_id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODULE 5: Extract event pairs
% This component extract pairs of events according to some temporal definition. 
% E.g. the parent was displaying the toy then the infant looked at the toy within 2 seconds.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('timevp_lib')
num_demo_subs = 10;

%% Overview
% Finds moments from two cevents that match a specified temporal relation
% 
% This function will loop through all events from Variable1 (by either specifying a csv file 
% or a variable name) and find those events in Variable2 that match the temporal  
% relation given in the threshold parameter. These matches (or pairs)
% are output in a resulting CSV file.
% 
%% Required Arguments
% filename1
%       -- string, the full path or relative path to a
%          .mat or .csv file
%       -- data can either be cstream or cevent format
%       -- if .mat, data should be saved under sdata.data structure, like
%          in multiwork format
%       -- for .csv files, one can specify the number of headers and
%          columns, see the optional arguments below
% filename2
%         -- see filename1
% timing_relation
%         -- string of characters that indicate the temporal relations
% 
%         on1 and off1 correspond to event1's onset and offset, respectively.
%         on2 and off2 correspond to event2's onset and offset, respectively.
% 
%         'more(A,B,T)' means A comes before B with a gap more than T seconds.
%         'less(A,B,T)' means A comes before B with a gap less than T seconds.
%         A and B are to be replaced with any combination of on1, off1, on2,
%         and off2. T is optional, and if it is not provided, will not
%         consider the gap between A and B.
% 
%         e.g.
%         timing_relation = 'more(on1, on2, 4)' means on1 must come before on2 in time,
%         with a gap of more than 4 seconds.
%         timing_relation = 'less(off2, on1, 2)' means off2 must come before on1 in time, with a
%         gap of less than 2 seconds.
% 
%         Note, you can chain multiple timing relations together using '&' or '|'. This
%         means AND and OR, respectively. Use parentheses to indicate
%         more complex timings.
%
%         e.g.  
%         timing_relation = 'more(on1, off1, 4) & less(on1, on2, 2)' means events in
%         Variable1 must be greater than 4 seconds long, and must start at most
%         2 seconds before the events in Variable2
% 
% mapping
%         -- Nx2 array that indicates which categories are to be matched
%            together.
% savefilename
%         -- string indicating where to save the CSV file. The folder
%            must exist.

if demo_id == 1
    filename1 = '.\yulab_data\1202\cevent_eye_roi_child.csv';
    filename2 = '.\yulab_data\1202\cevent_eye_roi_parent.csv';
    timing_relation = 'more(on1, off2, 0.3) & less(off1, on2, 1)';
    mapping = [(1:25)' (1:25)'];
    savefilename = fullfile('yulab_analysis', 'example_extract_pairs.csv');

    timevp_extract_pairs(filename1, filename2, timing_relation, mapping, savefilename);
elseif demo_id == 2
    % One can also extract pairs by a list of subjects, two variable names and
    % a folder to save all csv files.
    variable1 = 'cevent_eye_roi_child';
    variable2 = 'cevent_eye_roi_parent';
    subject_list = yulab_list_subjects('toyroom');
    subject_list = subject_list(1:num_demo_subs);
    timing_relation = 'more(on1, off2, 0.3) & less(off1, on2, 1)';
    mapping = [(1:25)' (1:25)'];
    
    dir_savefiles = 'yulab_analysis';
    timevp_extract_pairs_by_subject(subject_list, variable1, variable2, timing_relation, mapping, dir_savefiles);
end