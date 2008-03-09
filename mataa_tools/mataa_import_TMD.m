function [t,s,comments] = mataa_import_TMD (file);

% function [t,s,comments] = mataa_import_TMD (file)
%
% DESCRIPTION:
% Import time-domain data from a TMD file (see also mataa_export_TMD).
%
% INPUT:
% file: string containing the name of the file containing the data to be imported. The string may contain a complete path. If no path is given, the file is assumed to be located in the current working directory.
% 
% OUTPUT:
% t: time values (s)
% s: signal samples
% comments: cell string containing the comments in the data file (if any)
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
% Copyright (C) 2006,2007,2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 10. January 2008  (Matthias Brennwald): first version

if nargin == 0
    file = '';
end

if length (file) == 0
    error ('mataa_export_TMD: the file name must not be empty.');
end

t = [];
s = [];
comments = cellstr ('');
nc = 0;

[fid,msg] = fopen (file,'rt');

if fid == -1
    error (sprintf ('mataa_import_TMD: %s (file: %s).',msg,file))
end

l = fgetl (fid); % read first line
while ~(l < 0)
    l = fliplr (deblank (fliplr (l))); % remove trailing zeroes
    if ~strcmp (l(1),'*')
        x = str2num (l);
        t = [t;x(1)];
        s = [s;x(2)];
    else
        nc = nc+1;
        comments{nc} = fliplr (deblank (fliplr (l(2:end))));
    end
    l = fgetl (fid); % read next line
end

fclose (fid);
