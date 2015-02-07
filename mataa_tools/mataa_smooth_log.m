function [y,x] = mataa_smooth_log (yRaw,xRaw,step)

% function [y,x] = mataa_smooth_log (yRaw,xRaw,step)
%
% DESCRIPTION:
% This function smoothes a data set (xRaw,yRaw) reflecting a function y(x), where the size of the averaging bins of x increases exponentially. y may be a multi-dimensional function of x.
% 
% INPUT:
% yRaw, xRaw: vectors containing raw data corresponding to function y(x). 
% step: smoothing width in octaves (e.g. step = 1/12 gives smoothed data with 1/12-octave resolution)
%
% OUTPUT:
% y, x: vectors containing smoothed data. If y(x) is multi dimensional, y is a matrix.
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

xMin = min(xRaw);
xMax = max(xRaw);

step = 2^step;

n = round(log(xMax/xMin)/log(step));

x = logspace(log10(xMin),log10(xMax),2*n+1);
x = x(2:2:end-1);

lenY = length(x); % length of series
y = repmat(NaN,lenY,1);

for k=1:n
    l = find(xRaw >= x(k)/sqrt(step) & xRaw <= x(k)*sqrt(step));
    if ~isempty(l)
        y(k) = mean(yRaw(l));
    end
end

i = ~isnan(y);
x = x(find(i));
y = y(find(i));
