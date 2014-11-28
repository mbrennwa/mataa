function [t_start,t_rise] = mataa_guess_IR_start (h,t,verbose);

% function [t_start,t_rise] = mataa_guess_IR_start (h,t,verbose);
%
% DESCRIPTION:
% Try to determine the start and and rise time of an impulse response signal.
%
% Note: this function calculates the analytic signal to determine the envelope function of h(t), and then analyses the envolope curve to find t_start and t_rise. See, for instance: http://en.wikipedia.org/wiki/Analytic_signal .
%
% INPUT:
% h: impulse response
% t: time-values vector of impulse response samples (vector, in seconds), or, alternatively, the sampling frequency of h(t) (scalar, in Hz, the first sample in h is assumed to correspond to time t(1)=0).
% verbose (optional): if verbose=0, no user feedback is given. If not specified, verbose ~= 0 is assumed.
%
% OUTPUT:
% t_start: 'beginning' of h(t) (seconds)
% t_rise: rise time of h(t) (seconds)
%
% EXAMPLE:
% > [h,t] = mataa_IR_demo; % load demo data of an loudspeaker impulse response.
% > mataa_plot_IR(h,t); % plot the fake signal
% > [t_start,t_rise] = mataa_guess_IR_start(h,t)
%
% This gives t_start = 0.288 ms and t_rise = 0.0694 ms. In this example might therefore safely discard all data with t < t_start. In real-world use (with noise and Murphy's law against us), however, it might be worthwile to add some safety margin, e.g. using t_rise: discard all data with t < t_start - t_rise.
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

if ~exist('verbose','var')
    verbose=1;
end

if isscalar(t) % t is the sampling frequency
    t = [0 : 1/t : (length(h)-1)/t];
end

badShape = 'mataa_guess_IR_start: the signal does not look like a well-shaped impulse response.';

if (max(abs(h))-mean(h))/std(h) < 7
    if verbose
    	beep
    	disp('The signal has a low crest factor and does not look like a typical impulse response (is it masked by noise?). If you continue, you should not rely on the result...');
    	input('If you want to continue, press ENTER. To abort, press CTRL-C.');
    else
        error(badShape)
    end
end

% amplitude envelope of h:
mag = abs(mataa_signal_analytic(h));

[val,iMax] = max(mag);

iHalf = min(find(mag > mag(iMax)/2));

if isempty(iHalf)
	error(badShape)
end

a=0.25;
iLow = min(find(mag > a*mag(iMax)));
iHigh = min(find(mag > (1-a)*mag(iMax)));

t_rise = (t(iHigh)-t(iLow))/(1-2*a);
t_start = t(iHalf)-2*t_rise;

t_start = max(t_start,min(t)); % make sure we're not outside the range of t
