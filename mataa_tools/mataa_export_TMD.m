function mataa_export_TMD (t,s,comment,file);

% function mataa_export_TMD (t,s,comment,file);
%
% DESCRIPTION:
% Export time-domain data to a TMD file (or, in other words: export the samples a signal s(t) to an ASCII file). A TMD file is essentially an ASCII file containing two columns of data: time and signal samples. The 'TMD format' is modelled after the FRD format for frequency-domain data (see mataa_export_FRD for more information).
%
% INPUT:
% t: time values (seconds)
% s: signal samples
% comment: string containing a comment to be saved with the data, e.g. a description of the data. Use comment = '' if you do not want a comment in the data file.
% 
% OUTPUT:
% (none)
%
% DISCLAIMER:
% This file is part of MATAA.
% 
% MATAA is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% MATAA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with MATAA; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
% 
% Copyright (C) 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html


t = t(:);
s = s(:);

N = length (t);

if length (s) ~= N
    error ('mataa_export_TMD: s must be of the same size as t.')
end

if length (file) == 0
    error ('mataa_export_TMD: the file name must not be empty.');
end

if length (file) < 4
    file = sprintf ('%s.TMD',file); % append '.TMD'
end

if ~strcmp (upper (file(end-3:end)),'.TMD')
    file = sprintf ('%s.TMD',file); % append '.TMD'
end

if exist(file,"file")
    beep;
    overwrite = input(sprintf("File %s exists. Enter 'Y' or 'y' to overwrite, or anything else to cancel.",file),"s");
    if ~strcmp(lower(overwrite),"y")
        disp ('File not saved, user cancelled.')
        return
    else
        disp (sprintf('Overwriting %s...',file));
    end
end

[fid,msg] = fopen (file,'wt');

if fid == -1
    error (sprintf ('mataa_export_TMD: %s',msg))
end

fprintf (fid,'* TMD data written by MATAA on %s\n',datestr (now));

if ~isempty (comment)
    fprintf (fid,'* %s\n',comment);
end

for i = 1:N-1
    fprintf (fid,'%g\t%g\n',t(i),s(i))
end
fprintf (fid,'%g\t%g',t(N),s(N)) % print last line without line break

fclose (fid);
