clear;
addpath('timevp_lib'); 

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

%%
variable1 = 'cevent_eye_roi_child';
variable2 = 'cevent_eye_roi_parent';
subject_list = [7002 7003 7006];
timing_relation = 'more(on2, off1) & more(on1, on2)';
dir_savefiles = 'timevp_output_files';
%%
timevp_extract_pairs_by_subject(subject_list, variable1, variable2, timing_relation, dir_savefiles);

  