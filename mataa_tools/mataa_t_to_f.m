function f = mataa_t_to_f (t);

% function f = mataa_t_to_f (t);
%
% DESCRIPTION:
% Same as mataa_t_to_f0, but the component corresponding to f=0 is removed from the output.
%
% INPUT:
% (see mataa_t_to_f0).
% 
% OUTPUT:
% (see mataa_to_f0).
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

f = mataa_t_to_f0(t);
f = f(2:end); % remove f=0
