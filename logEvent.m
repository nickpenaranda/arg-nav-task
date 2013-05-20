function logEvent( entry )
% logEvent( entry )
%
% (Part of the Navigation Task Suite package)
% Creates a new log file if one doesn't exist and records a timestamped
% entry.  Logs are .csv files with 10 columns.  The first two are time
% in seconds since the experiment listener was created and the type of
% message.  The last 8 columns are generic placeholders for any kind of
% data that each record type needs to store
%
% entry                 Contents of the remainder of the string, where
%                       each field is separated by a comma, starting with
%                       the message type
%
% Example
% -------
%
% logEvent('MyEvent,20,true')
%
% --> Records "<timestamp>,MyEvent,20,true" to the current logfile
%
% Use sprintf to create more elaborate records.
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    
    if(exp.logFile == -1)
        % Init logfile
        logName = sprintf('data\\Log_%s_%s.csv', ...
            exp.participantNumber, ...
            datestr(now,'yy.mm.dd_HH.MM.SS'));
        exp.logFile = fopen(logName,'at');
        fprintf(exp.logFile,'time (s),message type,data1,data2,data3,data4,data5,data6,data7,data8\n');
    end

    record = sprintf('%f,%s\n',GetSecs() - exp.startTime,entry);
    
    try
        fprintf(exp.logFile, record);
    catch err
        disp('Failed to write record:');
        disp(record);
        disp(err.message)
    end
end

