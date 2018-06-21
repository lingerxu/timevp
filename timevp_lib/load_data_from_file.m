function loaded_data = load_data_from_file(filename, numheaders, columns)

loaded_data = [];

if ~strcmp(filename(end-2:end), 'csv')
    error('Wrong filename input: %s', filename);
end

loaded_data = dlmread(filename, ',', numheaders, 0);
if ~isempty(columns)
    loaded_data = loaded_data(:,columns);
end