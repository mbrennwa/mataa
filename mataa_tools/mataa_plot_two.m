function h = mataa_plot_two (x,y1,y2,figNum,plottit,xtit,y1tit,y2tit);

% function h = mataa_plot_two (x,y1,y2,figNum,plottit,xtit,y1tit,y2tit);
%
% DESCRIPTION:
% Plots y1 and y2 vs. x.
%
% INPUT:
% x: x values
% y1, y2: y values to be plotted vs. x. y2 may be empty (y2 = []), which will result in a single plot of y1 vs x.
% figNum: number (handle) of the figure window to be used for the plot. Use figNum = [] if the default window is to be used (e.g. the current plot window)
% plottit: plot title.
% xtit: x-axis label
% y1tit, y2tit: y-axis label of the y1 and y2 data
%
% OUTPUT:
% h: a 2-vector containig the handles to the axes of the two plots. If the second plot is omitted h(2) will be set to NaN,
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

h = repmat (NaN,2,1);

x = x(:);
y1 = y1(:);
y2 = y2(:);

if size (x) ~= size (y1)
    error ('mataa_plot_two: size of x and y1 data does not agree.')
end

if size (x) ~= size (y2)
    error ('mataa_plot_two: size of x and y2 data does not agree.')
end

color = mataa_settings ('plotColor');
if ~isempty(figNum)
    figure (figNum);
end
mataa_plot_defaults;

if length (y2) > 0
    subplot(2,1,1)
end

plot (x,y1,color)
title (plottit);
ylabel (y1tit);
xlabel (xtit);

h(1) = gca;

if length (y2) > 0
    subplot (2,1,2)
    plot (x,y2,color);
    ylabel (y2tit);
    xlabel (xtit);
    h(2) = gca;
end
