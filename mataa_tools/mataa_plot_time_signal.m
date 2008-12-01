function mataa_plot_time_signal (s,t,plottit,ytit,plotWindow);

% function mataa_plot_time_signal (s,t,plottit,xtit,ytit,plotWindow);
%
% DESCRIPTION:
% This function plots the signal s(t).
%
% INPUT:
% s: signal samples
% t: time values (vector, in seconds), or, alternatively, the sampling frequency of the signal (scalar, in Hz)
% plottit: plot title.
% xtit, ytit: labels for the x-axis and y-axis
% plotWindow: number (handle) of the figure window to be used for the plot. Use plotWindow = [] if the default window is to be used (e.g. the current plot window)
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

if ~isempty(plotWindow)
    figure (plotWindow);
end

if isscalar(t) % t is the sampling frequency
    t = [0 : 1/t : (length(s)-1)/t];
end

scale = 0;
while scale > ceil(log10(max(t)))
	scale = scale-3;
end

switch scale
    case  0
        unit = 's';
    case -3
        unit = 'ms';
    case -6
        unit = 'us';
    case -9
         unit = 'ns';
    otherwise
        unit = sprintf('10^{%i} s',scale);
end
mataa_plot_one (t/10^scale,s,plotWindow,plottit,sprintf ('Time (%s)',unit),ytit);
