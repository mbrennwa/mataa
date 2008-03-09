function mataa_plot_save(fileName);

% function mataa_plot_save(fileName);
%
% DESCRIPTION:
% Saves the last plot to an EPS (encapsulated post script) file.
% 'fileName' is the name (and path) of the file. If it does not include a path, the file is saved to the current directory (type 'pwd' to see the current directory).
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
% 27. December 2007 (Matthias Brennwald): replaced the experimental code to work around the missing print funcion of some outdated version of Octave by an error message complaining about the outdated Octave version.
% 21.4.2007 (Matthias Brennwald): removed code to automatically open the produced file (this caused more problems than anything else and did not work on platforms other than Mac OS X).
% first version: 9. December, Matthias Brennwald

if length(fileName) < 4
    fileName = [ fileName '.eps' ];
elseif ~strcmp(fileName(end-3:end),'.eps')
    fileName = [fileName '.eps'];
end

if exist('print')
    or = orient;
    orient('landscape');
    print('-dpsc',fileName);
    orient(or);
else
    error('mataa_plot_save: print function is missing. If you are using Octave, you may need to upgrade to a more current version of Octave (3.0 or loater is recommended).')
end