function mataa_signal_save (s,fs,file,description);

% function mataa_signal_save (s,fs,file,description);
%
% DESCRIPTION:
% Saves the signal s(t) to an binary file (Matlab 6 format).
%
% INPUT:
% ...
%
% OUTPUT:
% ...
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
% Copyright (C) 2006,2007 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 4. January 2008 (Matthias Brennwald): first version

if ~any (size (s) == 1)
    error ('mataa_signal_save: only signals containing one data channel are supported at the moment.')
end

if ~any (size (fs) == 1)
    error ('mataa_signal_save: only signals containing one data channel are supported at the moment.')
end

if ~isscalar(fs) % fs contains the time values
    fs = 1 / mean (diff (fs));
end

s = s(:);

if ~exist ('file','var')
    p = input (sprintf('Enter path to file (leave empty to use default %s): ',pwd),'s');
    if isempty (p)
        p = pwd;
    end
    if ~strcmp (p(end),filesep)
        p = sprintf ('%s%s',p,filesep);
    end
    if ~exist (p,'dir')
        error (sprintf ('mataa_save_signal: the directory ''%s'' does not exist.',p))
    end
    
    f = '';    
    while isempty (f)
        f = input ('Enter file name: ','s');
        if isempty (f)
            disp ('The file name must not be empty!')
        end
    end

    if length (f) < 4
        f = sprintf ('%s.mat',f);
    elseif ~strcmp (f(end-3:end),'.mat')
        f = sprintf ('%s.mat',f);
    end

    file = sprintf ('%s%s',p,f);

    clear f p
end

if ~exist ('description','var')
    description = input ('Enter a (short) description of the signal: ','s');
end

save ('-v6',file,'fs','s','description');