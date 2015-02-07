function [S,f] = mataa_realFT (s,t);

% function [S,f] = mataa_realFT (s,t);
%
% DESCRIPTION:
% Identical to mataa_realFT0, but without the component corresponding to f=0.
%
% INPUT:
% (see mataa_realFT0)
%
% OUTPUT:
% (see mataa_realFT0)
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
% Copyright (C) 2006,2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

[S,f] = mataa_realFT0(s,t);

% remove component corresponding to f=0:
S = S(2:end);
f = f(2:end);
