function name = mataa_file_default_name (ask);

% function name = mataa_file_default_name;
% 
% DESCRIPTION:
% This function returns a file name that can be used to save MATAA data. If 'ask' is nonzero, the user is asked to enter a file name. If no answer is given or if 'ask' is zero, a default file name made up of the current date and time of day is returned.
% 
% INPUT:
% ask: flag to specify if the user should be asked for a file name. If 'ask' is not specified, ask=0 is assumed.
% 
% OUTPUT:
% name: file name
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
% Copyright (C) 2006, 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

if ~exist('ask','var')
    ask = 0;
end

c = clock;
c = [ 'mataafile_' num2str(c(1)) '_' num2str(c(2)) '_' num2str(c(3)) '_' num2str(c(4)) '_' num2str(c(5)) '_' num2str(round(c(6))) '.mat' ];
cd(mataa_path('data'));
name = [];
if ask
    name = input(sprintf('Enter name of file to save data (default is ''%s'', path is %s): ',c,pwd),'s');
end

if isempty(name)
	name = c;
end

if ~strcmp(name(end-3:end),'.mat')
	name = [name '.mat'];
end
