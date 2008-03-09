function [f,mag,phase,comments] = mataa_import_FRD (file);

% function [f,mag,phase,comments] = mataa_export_FRD (file);
%
% DESCRIPTION:
% Import frequency-domain data from a FRD file.
% (see also mataa_export_FRD).
%
% INPUT:
% file: string containing the name of the file containing the data to be imported. The string may contain a complete path. If no path is given, the file is assumed to be located in the current working directory.
% 
% OUTPUT:
% f: frequency values (Hz)
% mag: magnitude values
% phase: phase
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 9. January 2008  (Matthias Brennwald): first version

if nargin == 0
    file = '';
end

if length (file) == 0
    error ('mataa_export_FRD: the file name must not be empty.');
end

f = [];
mag = [];
phase = [];
comments = cellstr ('');
nc = 0;

[fid,msg] = fopen (file,'rt');

if fid == -1
    error (sprintf ('mataa_import_TMD: %s (file: %s).',msg,file))
end

s = fgetl (fid); % read first line
while ~(s < 0)
    s = fliplr (deblank (fliplr (s))); % remove trailing zeroes
    if ~strcmp (s(1),'*')
        x = str2num (s);
        f = [f;x(1)];
        mag = [mag;x(2)];
        phase = [phase;x(3)];
    else
        nc = nc+1;
        comments{nc} = fliplr (deblank (fliplr (s(2:end))));
    end
    s = fgetl (fid); % read next line
end

fclose (fid);
