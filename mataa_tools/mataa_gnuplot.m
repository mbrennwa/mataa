function mataa_gnuplot (cmd);

% function mataa_gnuplot (cmd);
%
% DESCRIPTION:
% This function executes the gnuplot command 'cmd' by calling __gnuplot_raw__(cmd). This only makes sense with Octave if gnuplot is used as the plotting engine. IMPORTANT: THIS FUNCTION SHOULD NOT BE USED ANYMORE, BECAUSE THE GNUPLOT INTERFACE TO OCTAVE HAS CHANGED CONSIDERABLY IN OCTAVE 2.9.X. IT WILL PROPABLY BE CHANGED FURTHER, BREAKING THIS FUNCTION.
%
% INPUT:
% cmd: string containing the gnuplot command.
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
% Further information: http://www.audioroot.net/MATAA

warning('mataa_gnuplot: THE FUNCTION mataa_gnuplot SHOULD NOT BE USED ANYMORE, BECAUSE THE GNUPLOT INTERFACE TO OCTAVE HAS CHANGED CONSIDERABLY IN OCTAVE 2.9.X. IT WILL PROPABLY BE CHANGED FURTHER, BREAKING THIS FUNCTION.')

if ~exist('OCTAVE_VERSION','builtin')
    warning('mataa_gnuplot: talking to Gnuplot from within MATAA only makes sense with GNU Octave.')
else
    try
        v = OCTAVE_VERSION;
        
        i = findstr('.',v); v = v(1:i(2)-1);
        
        cmd = undo_string_escapes(cmd);
                
        switch v
            case '2.1' % v = 2.1.x, use single quotes:
                eval(sprintf('__gnuplot_raw__( ''%s ; \\n '')',cmd)); % the eval is needed to make Matlab read the file without complaining.
            case '2.9' % v = 2.9.x, use double quotes:
                eval(sprintf('__gnuplot_raw__( "%s ; \\n ")',cmd)); % the eval is needed to make Matlab read the file without complaining.
            otherwise
                warning('mataa_gnuplot: don''t know how to handle gnuplot commands with your version of GNU Octave.')
        end
    catch
        warning(sprintf('mataa_gnuplot: %s', lasterr))
    end
end
