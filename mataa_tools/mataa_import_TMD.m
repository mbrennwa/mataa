function [t,s,comments] = mataa_import_TMD (file,timefix);

% function [t,s,comments] = mataa_import_TMD (file,timefix)
%
% DESCRIPTION:
% Import time-domain data from a TMD file (see also mataa_export_TMD).
%
% INPUT:
% file: string containing the name of the file containing the data to be imported. The string may contain a complete path. If no path is given, the file is assumed to be located in the current working directory.
% timefix (optional): flag indicating if (and how) mataa_import_TMD should try to make time values evenly spaced. If timefix > 1: t = timefix * round (1/mean(diff(t))/timefix)
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
% Copyright (C) 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA
%
% EXAMPLE:
% 
% > [t,h,comments] = mataa_import_TMD ('scanspeaker_0deg_no_filter_tweeter.tmd',10);

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

%%% s = char (fread(fid,[2,Inf]));
%%% s = strsplit(s(1:end),"\n");

% read the header
try_header = 1;
while try_header
    l0 = fgetl (fid);
    if l0 == -1
        return
    else
        l = fliplr(deblank(fliplr(l0)));
        if strcmp (l(1),'*')
            nc = nc+1;
            comments{nc} = fliplr(deblank(fliplr(l)))(2:end);
        else
            try_header = 0;
            fseek (fid,-length(l0)-1,"cof"); % go back to beginning of the line
        end
    end
end

x = fscanf(fid, '%f%f', Inf);
fclose (fid);
x = reshape (x,2,length(x)/2)';
t = x(:,1);
s = x(:,2);

if exist ('timefix','var')
	if timefix > 1
		fs = timefix * round (1/mean(diff(t))/timefix);
		t  = t(1) + [ 0 : 1/fs : (length(s)-1)/fs ]';
	end
end

if max(diff(t)) - min(diff(t)) > 2.5*eps
	warning ('mataa_import_TMD: time values are not evenly spaced. Be careful!')
end