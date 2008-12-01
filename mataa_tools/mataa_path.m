function path = mataa_path (whichPath);

% function path = mataa_path (whichPath);
%
% DESCRIPTION:
% This function returns the Matlab / MATAA paths as specified by 'whichPath'
%
% INPUT:
% whichPath (optional): a string specifying which path should be retrieved.
% whichPath can be one of the following:
% 'main' (default)   the main MATAA path
% 'signals'          the path where the test signal data is stored
% 'tools'            the path where the MATAA 'tools' routines are stored (the MATAA toolbox)
% 'TestTone'         the path to the TestTone program
% 'TestDevices'      the path to the TestDevices program
% 'mataa_scripts'    the path to the MATAA scripts
% 'microphone'       the path to the microphone-data files
% 'settings'	     the path where the MATAA settings are stored
%
% If whichPath is not specified, it is set to 'main' by default.
% 
% OUTPUT:
% path: the MATAA path as indicated by whichPath (string)
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

if ~exist('whichPath')
    warning('mataa_path: no path specified, assuming whichPath=main.');
    whichPath = 'main';
end

main = which('mataa_path.m');
main = main(1:end-length('mataa_path.m'));

if length(main) > 1
if strcmp(main(end-1:end),sprintf('%s%s',filesep,filesep))
    main = main(1:end-1);
end
end

i1 = findstr(main,filesep);
i2 = findstr(main,'/'); % windows sometimes uses both '/' and '\' as file separators within a single path
i = unique([i1 i2]);
main = main(1:i(end-1));

switch whichPath
    case 'main',            path = main;
    case 'signals',         path = [main 'test_signals' filesep];
    case 'tools',           path = [main 'mataa_tools' filesep];
	case 'TestDevices',		path = mataa_path('TestTone');
    case 'TestTone',
    	plat = mataa_computer;
    	path = [main 'TestTone' filesep plat filesep];
    case 'mataa_scripts',     path = [main 'mataa_scripts' filesep];
%    case 'user_scripts',    path = [main 'user_scripts' filesep];
    case 'microphone',      path = [main 'microphone_data' filesep];
%    case 'data',            path = [main 'mataa_data' filesep];
    case 'settings',        path = ['~' filesep];
    otherwise               error(sprintf('mataa_path: Unkown path specifier (''%s'').',whichPath))
end
