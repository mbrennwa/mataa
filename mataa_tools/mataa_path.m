function pth = mataa_path (whichPath);

% function pth = mataa_path (whichPath);
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
% 'microphone'       the path to the microphone-data files - THIS IS DEPRECATED! The 'microphone' identifier is now mapped to the 'calibration' identifier.
% 'settings'	     the path where the MATAA settings are stored
% 'calibration'      the path where calibration files are stored (microphones, audio interfaces / soundcards, etc.)
%
% If whichPath is not specified, it is set to 'main' by default.
% 
% OUTPUT:
% pth: the MATAA path as indicated by whichPath (string)
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
% Further information: http://www.audioroot.net/MATAA

if ~exist('whichPath','var')
    warning('mataa_path: no path specified, assuming whichPath=main.');
    whichPath = 'main';
end

main = which('mataa_path');
main = main(1:end-length('mataa_path.m'));

if length(main) > 1
if strcmp(main(end-1:end),sprintf('%s%s',filesep,filesep))
    main = main(1:end-1);
end
end

i1 = strfind(main,filesep);
i2 = strfind(main,'/'); % windows sometimes uses both '/' and '\' as file separators within a single path
i = unique([i1 i2]);
main = main(1:i(end-1));

switch whichPath
    case 'main',            pth = main;
    case 'signals',         pth = [main 'test_signals' filesep];
    case 'tools',           pth = [main 'mataa_tools' filesep];
	case 'TestDevices',		pth = mataa_path('TestTone');
    case 'TestTone',
    	plat = mataa_computer;
    	pth  = [main 'TestTone' filesep plat filesep];
    case 'mataa_scripts',     pth = [main 'mataa_scripts' filesep];
%    case 'user_scripts',    pth = [main 'user_scripts' filesep];
    case 'microphone'
    	warning ('mataa_path: the ''microphone'' identifier is deprecated. Returning the ''calibration'' path instead.')
    	pth = mataa_path ('calibration');
    case 'calibration',      pth = [main 'calibration' filesep];
%    case 'data',            pth = [main 'mataa_data' filesep];
    case 'settings',        
        if strcmp (mataa_computer,'PCWIN')
        	if exist ('userpath'); % userpath seems to be Matlab only
	            pth = userpath;
	        else % get first entry on the searchpath, as documented on the Matlab website
	        	pth = strsplit (path,pathsep);
	        	pth = pth{1};
	        end
            if isempty(pth) % userpath may be return an empty string on Windows (argh!)
                pth = pwd;
                warning('mataa_path: Windows userpath empty, using current working directory (pwd) as settings path.');
            end
            if strcmp(pth(end),';')
                pth = pth(1:end-1);
            end
            if ~strcmp(pth(end),filesep)
                pth = [ pth filesep ];
            end
        else
            pth = ['~' filesep]; % this may cause issues if the tilde is not supported, e.g. on fancy Windows systems
        end
    otherwise               error(sprintf('mataa_path: Unkown path specifier (''%s'').',whichPath))
end
