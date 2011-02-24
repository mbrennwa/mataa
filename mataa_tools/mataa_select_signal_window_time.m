function [t_start,t_end] = mataa_select_signal_window_time;

% function [t_start,t_end] = mataa_select_signal_window_time;
% 
% DESCRIPTION:
% Interactively select start and end times of a signal.
%
% INPUT:
% (none)
%
% OUTPUT:
% t_start: start of selected signal range
% t_end: end of selected signal range
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

% input('Make shure that the window showing the signal-plot is active, and the zoom is set accordingly (press ENTER to confirm)...')

r = axis;

disp('Click on start of signal (press ENTER to confirm)...');
fflush (stdout);
[x,y] = ginput;
t_start=x(end); % use last value before ENTER was pressed;
disp(sprintf('  t_start = %g\n', t_start));  fflush (stdout);

line([t_start t_start],[-1 1],'Color',0.5*[1 1 1]); axis (r);

disp('Click on end of signal (press ENTER to confirm)...');  fflush (stdout);
[x,y] = ginput;
t_end=x(end); % use last value befor ENTER was pressed;
disp(sprintf('  t_end = %g\n', t_end));  fflush (stdout);

disp(sprintf('  T = t_end - t_start = %g\n', t_end-t_start));  fflush (stdout);
disp(sprintf('  f_min = 1/T = %g\n', 1/(t_end-t_start)));  fflush (stdout);

line([t_end t_end],[-1 1],'Color',0.5*[1 1 1]); axis (r);
