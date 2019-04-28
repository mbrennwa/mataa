function [f,mag,phase,comments] = mataa_import_FRD (file);

% function [f,mag,phase,comments] = mataa_import_FRD (file);
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
% Copyright (C) 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA
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

% read the header
try_header = 1;
while try_header
    pos = ftell (fid); % current file positions
    l0 = fgetl (fid);
    l = fliplr(deblank(fliplr(l0)));
    if strcmp (l(1),'*')
        nc = nc+1;
        comments{nc} = fliplr(deblank(fliplr(l)))(2:end);
    else
        try_header = 0;
	fseek (fid, pos, SEEK_SET); % go back to the beginning of the first data line
    end
end

x = fscanf(fid, '%f%f', Inf);
fclose (fid);

x = reshape (x,3,length(x)/3)';
f = x(:,1);
mag = x(:,2);
phase = x(:,3);
