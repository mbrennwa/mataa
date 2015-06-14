function y = mataa_interp (xi,yi,x);

% function y = mataa_interp (xi,yi,x);
%
% DESCRIPTION:
% Linear interpolation of y(x) from yi(xi)
% if x is outside the range of xi, mataa_interp returns a linear extrapolation of the yi
%
% Linear interpolation is of course available in Matlab and Octave-Forge as interp1. However, it's not available in plain-vanilla Octave, which is a shame, I think (this was fixed a while ago, so mataa_interp is obsolete and may be removed in the future). I therefore provided this function for MATAA so that I don't have to worry about interp1 missing in Octave while still being able to easily write code that is compatible with both Matlab and Octave.
%
% FIXME: THIS CODE IS AS INEFFICIENT AS IT GETS!
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

if exist('interp1','file')
    y = interp1(xi,yi,x,'linear','extrap');
else
    X = x;
    Y = repmat(NaN,size(X));
    
    for k=1:length(X)
        x = X(k);
        n=find(x==xi);
        
        if ~isempty(n)
        	y=yi(n);
        else
        	nLow = max(find(xi < x));
        	nHigh = min(find(xi > x));
        	
        	if isempty(nLow)
        		y = yi(1) + (yi(2)-yi(1))/(xi(2)-xi(1)) * (x-xi(1));
        	elseif isempty(nHigh)
        		y = yi(end) + (yi(end)-yi(end-1))/(xi(end)-xi(end-1)) * (x-xi(end));
        	else
        		a = (x-xi(nLow)) / (xi(nHigh)-xi(nLow));
        		y = a*yi(nHigh) + (1-a)*yi(nLow);
        	end
        end
        Y(k)=y;
    end
    
    y=Y;
end
