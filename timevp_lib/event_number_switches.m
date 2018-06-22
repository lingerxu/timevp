function [results, switch_mask] = cevent_number_switches(cevents, categories)

% This function calculates the number of switches between different
% categorical values.
%
% last update by txu@indiana.edu May. 2013, please contact for any problems

if ~isempty(cevents)
    if exist('categories', 'var')
        cevents = cevents(ismember(cevents(:,3), categories), :);
    end
end

if isempty(cevents)
    results = 0;
    switch_mask = zeros(zeros, 1);
else

    
    last_roi = cevents(1, 3);
    results = 0;
    switch_mask = zeros(size(cevents, 1), 1);
    switch_mask(1,1) = 1;

    for cidx = 2:size(cevents, 1)
        current_roi = cevents(cidx, 3);
        if last_roi ~= current_roi
            results = results + 1;
            switch_mask(cidx,1) = 1;
        end
        last_roi = current_roi;
    end
end
    
