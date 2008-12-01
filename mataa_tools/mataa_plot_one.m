function h = mataa_plot_one (x,y,figNum,plottit,xtit,ytit);

% function h = mataa_plot_one (x,y,figNum,plottit,xtit,ytit);
%
% DESCRIPTION:
% Plots y vs. x.
%
% INPUT:
% x: x values
% y: y values to be plotted vs. x.
% figNum: number (handle) of the figure window to be used for the plot. Use figNum = [] if the default window is to be used (e.g. the current plot window)
% plottit: plot title.
% xtit: x-axis label
% ytit: y-axis label
%
% OUTPUT:
% h: handle to the axes of the plot.
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

h = NaN;

x = x(:);
y = y(:);

if size (x) ~= size (y)
    error ('mataa_plot_one: size of x and y data does not agree.')
end

color = mataa_settings ('plotColor');
if ~isempty(figNum)
    figure (figNum);
end
mataa_plot_defaults;

plot (x,y,color)
title (plottit);
ylabel (ytit);
xlabel (xtit);

h = gca;
