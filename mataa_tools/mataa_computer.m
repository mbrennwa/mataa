function platform = mataa_computer;

% function platform = mataa_computer;
%
% DESCRIPTION:
% Returns the current computer platform.
%
% INPUT:
% (none)
%
% OUTPUT
% platform: string indicating the computer platform:
% MAC:      Mac OS X (Darwin)
% PCWIN:    MS Windows
% PCLINUX:  Linux on Intel/AMD
% UNKNOWN:  unknown platform (unknown to MATAA)
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
% 25. Feb 2007 (Matthias Brennwald): fixed UNKNOWN response with Matlab on Intel-Mac (Matlabs 'computer' returns 'MACI' instead of 'MAC'). 
% 8. Feb 2007 (Matthias Brennwald): added MS-Windows / 'PCWIN'

platform = computer;

if (exist('OCTAVE_VERSION')~=0) % we're running Octave
	if (~isempty(findstr(platform,'apple')) && ~isempty(findstr(platform,'darwin')))
		platform='MAC';
	elseif ~isempty(findstr(platform,'pc-linux')) % e.g. platform = 'i586-pc-linux-gnu'
		platform='PCLINUX';
    elseif ~isempty(findstr(platform,'-pc-')) % e.g. platform = 'i686-pc-cygwin'
		platform='PCWIN';
	else
		platform='UNKNOWN';
	end
else
% we're running matlab

    if strcmp(platform,'MACI') % Intel MAC
        platform = 'MAC'
    end
    
	if ( ~strcmp(platform,'MAC') && ~strcmp(platform,'PCWIN') )
		platform='UNKNOWN';
	end
	
end