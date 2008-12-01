function [version,subversion,subsubversion] = mataa_octave_version

% function [version,subversion,subsubversion] = mataa_octave_version
%
% DESCRIPTION:
% Returns the Octave version. If called with Matlab, the output values are set to NaN.
% 
% INPUT:
% (none)
% 
% OUTPUT:
% version: main version
% subversion: subversion
% subsubversion: subsubversion
%
% EXAMPLE:
% With Octave 2.1.73, the output is:
% version = 2
% subversion = 1
% subsubversion = 73
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
% Copyright (C) 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

if exist('OCTAVE_VERSION','builtin')
    v = OCTAVE_VERSION;
    p = findstr('.',v);
    version = str2num(v(1:p(1)-1));
    subversion = str2num(v(p(1)+1:p(2)-1));
    subsubversion = str2num(v(p(2)+1:end));
else
    version = NaN;
    subversion = NaN;
    subsubversion = NaN;
end
    
