function [s,t] = mataa_signal_pad_Zeros(s0,t0,T);

% function [s,t] = mataa_signal_pad_Zeros(s0,t0,T);
%
% DESCRIPTION:
% This function pads a signal s0(t0) with zeroes, i.e. replaces signal s0(t0) with s(t), where...
% ...s(t=t0) = s0(t0)
% ...s(t>max(t0) and t<T) = 0
%
% The new signal s(t) therefore has length T
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
% first version: 9. July 2006, Matthias Brennwald

if (max(t0)-min(t0)) > T
	warning('Signal is longer than desired length after zero padding. No zero padding applied.')
	s = s0;
	t = t0;
else
	dt = t0(2)-t0(1);
	
	% make sure we've got column vectors:
	t0 = reshape(t0,length(t0),1);
	s0 = reshape(s0,length(s0),1);
	
	% make sure T is multiple of dt:
	T = round(T/dt)*dt;
	
	% pad the signal
	T = [t0(end)+dt:dt:T]';
	t = [ t0 ; T ];
	s = [ s0 ; repmat(0,length(T),1) ];
end