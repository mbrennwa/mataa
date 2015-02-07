function [t,s] = mataa_import_AIFF (file);

% function [t,s] = mataa_import_AIFF (file)
%
% DESCRIPTION:
% Import time-domain data from an AIFF file. This function requires the sndfile-convert utiliy, which is part of libsndfile ( http://www.mega-nerd.com/libsndfile ).
%
% INPUT:
% file: string containing the name of the file containing the data to be imported. The string may contain a complete path. If no path is given, the file is assumed to be located in the current working directory.
% 
% OUTPUT:
% t: time values (s)
% s: signal samples
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

% convert the AIFF file to a MAT file:
outfile = sprintf ('%s.mat',tmpnam);
cmd     = sprintf ('sndfile-convert %s %s',file,outfile);
[status, output] = system (cmd);

X = load (outfile); % load the mat file

delete (outfile); % clean up

s = X.wavedata; s = s(:);
t = linspace (0,(length(s)-1)/X.samplerate,length(s)); t = t(:);