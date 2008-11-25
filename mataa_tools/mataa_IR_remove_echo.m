function [h,t] = mataa_IR_remove_echo (h,t,t_echo_start,t_echo_end);

% function [h,t] = mataa_IR_remove_echo (h,t,t_echo_start,t_echo_end);
%
% DESCRIPTION:
% This function removes echos from an impulse response. The echos are replaced by data calculated by linear interpolation.
%
% INPUT:
% h: values impulse response (vector)
% t: time values of samples in h (vector)
% t_echo_start: start time of echo
% t_echo_end: end time of echo
%
% OUTPUT:
% h: values impulse response with echo removed
% t: time values of samples in h
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
% Copyright (C) 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% first version: 25. November 2008, Matthias Brennwald

ii = find (t < t_echo_start | t > t_echo_end);


h  = interp1 (t(ii),h(ii),t);