function t = mataa_f_to_t(f);

% function t = mataa_f_to_t(f);
%
% DESCRIPTION:
% returns the time bins of the inverse fourier spectrum sampled at frequencies f (f is assumed to be evenly spaced!)
%
% INPUT:
% f: frequency-value vector (in Hz). Values must be sorted and evenly spaced.
% 
% OUTPUT:
% t: time values (vector, in seconds)
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 8. November 2007 (Matthias Brennwald): improved documentation
% first version: 22. July 2006, Matthias Brennwald

if any (f<0)
    error ('mataa_f_to_t: f must not contain negative values.')
end

f = sort (f); % make sure f is sorted

l=length(f)

if f(1) ~= 0
    T = 1/f(1);
else
    T = 1/f(2);
end

if mod(l,2)
    dt = T/(2*l+1);
else
    dt = 1/(2*f(end));
end

t = [0:dt:T-dt]';