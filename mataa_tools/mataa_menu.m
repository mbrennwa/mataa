function out = mataa_menu (title, varargin)

% function out = mataa_menu (title, varargin)
%
% DESCRIPTION:
% This function prints a menu and asks the user to choose a command from the menu.
%
% title: the tile of the menu (string)
% varargin: a list of menu entries as described in the below example
% out: the command chosen by the user
%
% EXAMPLE:
%
% To print a menu with the title 'Main menu' and the commands 'measure', 'plot', 'save' and 'exit':
% choice = mataa_menu('Main menu','m','measure','p','plot','s','save','e','exit');
% 
% The result will look like this:
% -----------
%     Main menu:
%     [m] measure  --  [p] plot  --  [s] save  --  [e] exit
%     
%     Choose a command: 
% -----------
% The user then chooses one of the four commands by entering 'm', 'p', 's' or 'e'. If he/she enteres something else, an error message will be shown, and the menu is displayed again.
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
% Force pending output to appear before the menu.
    fflush (stdout);
end

N = nargin-1;
if mod(N,2)
    error('mataa_menu: list of options is corrupted or incomplete')
end
N = N/2;

done = false;

while(~done)
    printf('\n')
    if (~isempty(title))
        disp(strcat(title,':'));
    end
    for i = 1:N
        o = varargin{2*i-1};
        t = varargin{2*i};
        printf("[%s] %s",o,t);
        if i < N
            printf("  --  ");
        else
            printf("\n");
        end
    end
    
    printf('\n')
    s = input ("Choose a command: ", "s");
    
    for i = 1:N
        if strcmp(varargin{2*i-1},s);
            done = true;
            out = s;
            break
        end
    end
    if ~done
        printf('\n')
        disp('Invalid command! Try a again...');
    end
end
