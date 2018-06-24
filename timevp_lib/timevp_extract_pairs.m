function [allpairs, events1_wo, events2_wo] = timevp_extract_pairs(filename1, filename2, timing_relation, savefilename, mapping, args)

NUM_DEFAULT = 150;

if ~exist('args', 'var') || isempty(args)
    args = struct();
end

if ~isfield(args, 'files_numheaders')
    args.files_numheaders = zeros(1, 2);
end

if ~isfield(args, 'files_columns')
    args.files_columns = cell(1, 2);
end

if ~exist('mapping', 'var') || isempty(mapping)
    mapping = [(1:NUM_DEFAULT)' (1:NUM_DEFAULT)'];
end

if isfield(args, 'sample_rate')
    sample_rate = args.sample_rate;
else
    sample_rate = timevp_config_dataset_info();
end
% 
% if ~isfield(args, 'cevent_trials_numheaders')
%     args.cevent_trials_numheaders = 0;
% end
% 
% if ~isfield(args, 'cevent_trials_columns')
%     args.cevent_trials_columns = [];
% end
% 
% if isfield(args, 'cevent_trials')
%     if ischar(args.cevent_trials)
%         args.cevent_trials = load_data_from_file(args.cevent_trials, args.cevent_trials_numheaders, args.cevent_trials_columns);
%     end
% end
% 
% if ~isfield(args, 'cevent_trials')
%     args.cevent_trials = [];
% end

events1 = load_data_from_file(filename1, args.files_numheaders(1), args.files_columns{1});
if size(events1, 2) == 2
    events1 = stream2event(events1, sample_rate);
end

events2 = load_data_from_file(filename2, args.files_numheaders(2), args.files_columns{2});
if size(events2, 2) == 2
    events2 = stream2event(events2, sample_rate);
end

[allpairs, events1_wo, events2_wo] = extract_pairs(events1, events2, timing_relation, mapping, args);
allpairs = allpairs(:, 1:end-1); % , pair type' last column is confusing

h1 = sprintf('%s,%s,,,%s,,,',strrep(strrep(timing_relation, ' ', '_'), ',', ';'), filename1, filename2);
h2 = sprintf('onset1, offset1, category1, index1, onset2, offset2, category2, index2');
headers = {h1, h2};

if exist('savefilename', 'var') && ~isempty(savefilename)
    write2csv(allpairs, savefilename, headers);
    
    h1 = sprintf('%s,%s,,,,',strrep(strrep(timing_relation, ' ', '_'), ',', ';'), filename1);
    h2 = sprintf('onset, offset, cat, index');
    headers = {h1, h2};
    write2csv(events1_wo, strrep(savefilename, '.csv', '_events1.csv'), headers);
    
    h1 = sprintf('%s,%s,,,,',strrep(strrep(timing_relation, ' ', '_'), ',', ';'), filename2);
    headers = {h1, h2};
    write2csv(events2_wo, strrep(savefilename, '.csv', '_events2.csv'), headers);
end

end