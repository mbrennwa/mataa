function [etc,t] = mataa_IR_to_ETC(h,t);

% function [etc,t] = mataa_IR_to_ETC(h,t);
%
% DESCRIPTION:
% This function calculates the energy-time-curve (ETC) from the impulse response h(t).
% The ETC is the envelope (magnitude) of the analytic signal of h (see D'Appolito, J.: Testing Loudspeakers, p. 125)
%
% INPUT:
% h: impulse response (in volts)
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
%
% OUTPUT:
% etc: energy-time curve
% t: time coordinates of etc (in seconds)
% 
% EXAMPLE:
% > [h,t] = mataa_IR_demo;
% > [etc,t] = mataa_IR_to_ETC(h,t);
% > mataa_plot_ETC_lin(etc,t)
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
% 14. July 2006 (Matthias Brennwald): first version

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

etc = abs( h + i*mataa_hilbert(h));