function [A,tau,f] = mataa_IR_to_TBES (h,t,f);

% function [A,tau,f] = mataa_IR_to_TBES (h,t,f);
%
% DESCRIPTION:
% Calculate tone burst energy storage (TBES) data. The impulse response is convolved with shaped tone burst(s) to analyze the transient response and energy storage of the DUT at different frequencies. Tone burst signals used are 4 cycles of pure sine with a Blackman envelope.
% The method is based on the ideas of Siegfried Linkwitz (see http://www.linkwitzlab.com/frontiers_2.htm#M ) and Jochen Fabricius.
%
% INPUT:
% h: values impulse response (vector)
% t: time values of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% f: frequency value(s) of tone burst (Hz)
%
% OUTPUT:
% A: amplitude envelope (dB, relative to max value)
% tau: dimensionless time value (time normalized by period of burst frequency)
% f: frequency values (same values as in input, useful for plotting TBES results)
%  
% EXAMPLE:
% > [h,t] = mataa_IR_demo ('FE108');
% > f = logspace (2,4,50);
% > [A,tau,f] = mataa_IR_to_TBES (h,t,f);
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

if isscalar(t)
	fs = t;
else
	fs=(length(t)-1)/(max(t)-min(t));
end

% make sure we've got column vectors:
h = h(:);
t = t(:);

N = 4; % number of sine cycles in tone burst

% initialize A, tau and ff:
A = tau = ff = [];

for i = 1:length(f) % loop for each frequency
	
	% calculate shaped tone burst:
	T = 1/f(i);
	b0 = mataa_signal_generator ('sine',fs,N*T,f(i));
	b0 = mataa_signal_window (b0(:),'blackman');
	
	% pad zeros to make room for ringing / signal decay and delay of impulse response:
	b0 = [b0 ; repmat(0,length(b0),1) ];
	
	% convolve shaped tone burst with impulse response:
	if length(b0) < length(h) % pad b0 with zeros
		b0 = [b0 ; repmat(0,length(h)-length(b0),1) ];
	elseif length(b0) > length(h) % pad h with zeros
		h = [h ; repmat(0,length(b0)-length(h),1) ];
	end
	b = mataa_convolve (b0,h);
		
	% calculate signal envelope:
	a = abs ( mataa_signal_analytic (b) );
	
	% determine lag of b relative to b0
	[r,lag] = xcorr (b,b0); [R,K] = max(r.^2); lag = lag(K);
	
	% throw away data before (theoretical) max of burst envelope:
	% (envelope of original burst (b0) has max at time N/2*T)
	k = round ( (N/2)*T*fs + lag ); % index to expected max value of envelope
	a = a(k:end);
	
	% normalized time
	t = [0:1/fs:(length(a)-1)/fs] / T;
	
	% add results to A, tau, and ff:	
	A   = [ A ; a(:) ];
	tau = [ tau ; t(:) ];
	ff  = [ ff ; repmat(f(i),length(a),1) ];
		
end % for i = 1:length(f)

f = ff;

% convert to dB (relative to max):
A = 20*log10(A);
A = A - max(A);
