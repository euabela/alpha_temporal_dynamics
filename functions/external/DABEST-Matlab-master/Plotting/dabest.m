function stat = dabest(csvFile, varargin)

d = readtable(csvFile);
identifiers = d(:,{'Identifiers'});
identifiers = table2cell(identifiers);
data = d(:,{'Values'});
data = table2array(data);
close(gcf);

if length(varargin) > 0
    if strcmp(varargin{1},'Paired');
        [stat] = FscatJit2(identifiers, data,'Y')
    
    else strcmp(varargin{1},'mergeGroups');
        [stat,avr,moes] = FscatJit2_mergeGroups(identifiers, data)
    end
else
    [stat] = FscatJit2(identifiers, data)
end

end