function [s,t] = mataa_realIFT (S,f);

% function [s,t] = mataa_realIFT (S,f);
%
% DESCRIPTION:
% Same as mataa_realIFT0, but without f=0.
%
% INPUT:
% S: complex fourier spectrum of the signal ('positive' half, see also DESCRIPTION).
% f: frequency values (vector)
%
% OUTPUT:
% s: signal samples (real-valued samples)
% t: time values of the signal
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
%
% HISTORY:
% 23. Sept. 2008: created this file (Matthias Brennwald)

if f(1) ~= 0
    f = [0 ; f];
    S = [0 ; S];
end

[s,t] = mataa_realIFT0 (S,f);