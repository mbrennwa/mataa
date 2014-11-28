% This script runs various tests to check the set up of MATAA
%
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

if exist('OCTAVE_VERSION','builtin')
	more('off'),
end

disp('****** MATAA demo: loudspeaker analysis ******')
input('Hit ENTER key to start.');

disp('First, load impulse-response data from disk, apply a half-Hann window, and plot it...')

[h,t] = mataa_IR_demo;

[t_start,t_rise] = mataa_guess_IR_start(h,t);

max_window_length = t(end)-t(1);
[h,t] = mataa_signal_crop(h,t,t_start,t_start+max_window_length);
h = mataa_signal_window(h,'hann_half');
mataa_plot_IR(h,t,'half-Hann window');
input('...done. Hit ENTER to continue.');

disp('Calculate the step response, and plot it...');
s = mataa_IR_to_SR(h,t);
mataa_plot_SR(s,t,'half-Hann window');
input('...done. Hit ENTER to continue.');

disp('Calculate and plot the frequency response (magnitude & phase, smoothed to 1/48 octave)...');
[spl,phase,f] = mataa_IR_to_FR(h,t,1/48);
% phase = mataa_phase_remove_trend(phase,f,300,3000);
phase = mataa_phase_remove_trend(phase,f);
mataa_plot_FR(spl,phase,f,'half-Hann window',2000);
input('...done. Hit ENTER to continue.');

disp('Calculate and plot the cumulative spectral decay (CSD, smoothed to 1/48 octave). This may take a while...');
T = linspace(0,0.005,40);
[spl,f,d] = mataa_IR_to_CSD(h,t,T,1/48);
mataa_plot_CSD(spl,f,d,50);
if exist('OCTAVE_VERSION','builtin')
	disp('...done (plot may take a while to appear).')
else
    disp('...done.')
end
disp('****** MATAA demo completed ******')
