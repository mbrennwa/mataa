function a = mataa_signal_analytic (s);

% function a = mataa_signal_analytic (s);
%
% DESCRIPTION:
% Calculate analytic signal a of signal s.
%
% INPUT:
% s: vector containing the samples values of the signal.
% 
% OUTPUT:
% a: vector containing the analytic signal of s.
% 
% EXAMPLE:
% calculate the amplitude envelope of the impulse response of a loudspeaker
% > [h,t] = mataa_IR_demo;        % load demo impulse response
% > a = mataa_signal_analytic(h); % calculate analytic response
% > a = abs(a);                   % abs(a) is the amplitude envelope of impulse response
% > plot(t,a);
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
% Copyright (C) 2007 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

a = s + i*mataa_hilbert(s);
