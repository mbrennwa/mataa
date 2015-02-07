function mataa_plot_IR (h,t,annote);

% function mataa_plot_IR (h,t,annote);
%
% DESCRIPTION:
% This function plots the impulse response h(t).
%
% INPUT:
% h: impulse response samples
% t: time coordinates of impulse response samples (vector, in seconds), or, alternatively, the sampling frequency of h(t) (scalar, in Hz)
% annote (optional): text note to be added to the plot title.
%
% EXAMPLE:
% > [h,t] = mataa_IR_demo;
% > mataa_plot_IR(h,t,'demo impulse response');
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

if ~exist('annote','var')
    annote = '';
end

if length (annote) > 0
    annote = sprintf (' (%s)',annote);
end

annote = sprintf ('MATAA: Impulse response%s',annote);

mataa_plot_time_signal (h,t,annote,'Impulse response',mataa_settings ('plotWindow_IR'));
