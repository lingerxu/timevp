function matrix = cevent_transition_matrix(cevent, max_gap, category_num)
% cevent_transition_matrix   Generate a transition matrix of the input cevent.
%
% matrix =  cevent_transition_matrix(cevent, max_gap);
%    matrix:   the transition matrix, where matrix(i, j) is the count of 
%                the transitions between cevent value i to cevent value j.
%    cevent:   cevent data
%    max_gap:  the maximum gap (in second) between two intervals that will be
%              counted as a transition. The default value of "max_gap" is Inf.
%    category_num: The number of category for this cevent. The default
%                  is the largest event value found in the input "cevent".
% Example :
% > cevent_data = [69.0280   69.9450    1.0000;
%                72.5080   73.8050     4.0000;
%                75.4820   87.1540     1.0000;
%                91.3940  104.1530     4.0000;
%                108.3860  111.1130    4.0000;
%                103.1310  121.1620    1.0000;
%                122.7510  123.5740    1.0000;                      
%                150.0210  153.8760    4.0000;
%                154.0310  155.9760    1.0000]
% 
% > matrix =  cevent_transition_matrix(cevent_data)
% 
% matrix =
% 
%      1     0     0     3
%      0     0     0     0
%      0     0     0     0
%      3     0     0     1
% 
% > matrix =  cevent_transition_matrix(cevent_data, 5)
%  
% matrix =
% 
%      1     0     0     2
%      0     0     0     0
%      0     0     0     0
%      3     0     0     1
%  
% > matrix =  cevent_transition_matrix(cevent_data,5, 6)
% 
% matrix =
% 
%      1     0     0     2     0     0
%      0     0     0     0     0     0
%      0     0     0     0     0     0
%      3     0     0     1     0     0
%      0     0     0     0     0     0
%      0     0     0     0     0     0
%

if ~exist('max_gap', 'var')
    max_gap = Inf;
end
data = cevent(:,3);

if ~exist('category_num', 'var')
    category_num = max(data);
end

matrix = zeros(category_num, category_num);
for i=2:length(data)
    if cevent(i, 1) - cevent(i-1, 2) <= max_gap  % The gap between two events shouldn't be larger than max_gap
        matrix(data(i-1),data(i)) = matrix(data(i-1),data(i)) + 1;
    end
end

end
