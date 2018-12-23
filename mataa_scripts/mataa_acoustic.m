% Use this script for acoustic measurements of impulse response
% (step response and SPL response are also calculated and plotted on screen, but not saved to disk).
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
% 
% Copyright (C) 2018 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

% sample rate:
if ~exist('fs','var')
	fs = input ('Enter sampling rate (Hz): ')
end
disp (sprintf('Sampling rate fs = %g Hz',fs))

% sine sweep:
if ~exist('T','var')
	T = input ('Sine sweep duration (s): ')
end
disp (sprintf('Sine sweep duration T = %g s',T))

if ~exist('fL','var')
	fL = input ('Sine sweep start frequency (Hz): ')
end
fL = max([1/T,fL]);
disp (sprintf('Sine sweep start frequency fL = %g Hz',fL))

if ~exist('fH','var')
	fH = input ('Sine sweep end frequency (Hz): ')
end
fH = min([fs/2,fH]);
disp (sprintf('Sine sweep end frequency fH = %g Hz',fH))

if ~exist('U0rms','var')
	U0rms = input ('Sine sweep amplitude (V-RMS): ')
end
disp (sprintf('Sine sweep amplitude U0rms = %g V-RMS',U0rms))

if ~exist('loopback','var')
	x = input ('Do you want to use loopback compensation (Y/n)?','s');
	if isempty(x)
		x = 'Y';
	end
	if upper(x) == 'Y'
		loopback = 1;
	else
		loopback = 0;
	end
end
if loopback
	kDUT = mataa_settings('channel_DUT');
	kREF = mataa_settings('channel_REF');
	
	calfile = {};
	calfile{kDUT} = 'MB_ACOUSTIC_CHAIN_DUT.txt';
	calfile{kREF} = 'MB_ACOUSTIC_CHAIN_REF.txt';

	disp (sprintf('DUT --> channel %i, calibration file %s',kDUT,calfile{kDUT}));
	disp (sprintf('REF --> channel %i, calibration file %s',kREF,calfile{kREF}));

else
	calfile = 'MB_ACOUSTIC_CHAIN_DUT.txt';
	disp (sprintf('DUT --> channel %i',mataa_settings('channel_DUT')));
	disp (sprintf('Calibration file = %s',calfile))
end		

% cut-off / time gate:
if ~exist('fc','var')
	fc = input ('Enter lower cut-off frequency (--> gate time) (Hz): ')
end
disp (sprintf('Time-domain gating / cut-off frequency fc = %g Hz',fc))

% SPL smoothing / resolution:
if ~exist('res','var')
	res = input ('SPL response smoothing (octave-fraction, leave empty for no smoothing): ')
end
if res <= 0
	res = [];
end
if isempty(res)
	disp ('No SPL response smoothing')
else
	disp (sprintf('SPL response smoothing 1/res = 1/%i octave',res))
end

% Plot color:
if ~exist('col','var')
	col = input ('Plot color (char: k, r, g, b, c, m, y): ','s');
end
if isempty ('col')
	col = 'r';
end
disp (sprintf('Plot color col = %s',col))
style = sprintf('%s-',col);


% Ready? Input ok?
input ('Ready to start? Press ENTER...')
 
% test signal:
s0 = mataa_signal_generator ('sweep',fs,T,[fL fH]); % log-sweep from fL to fH
s0 = s0 * U0rms/sqrt(sum(s0.^2)/length(s0)); % normalise to desired RMS level

% measure impulse response:
[h,t,unit] = mataa_measure_IR (s0,fs,1,0.2,loopback,calfile,'V');

% time gating:
[t_start,t_rise] = mataa_guess_IR_start (h,fs);
[hh,th] = mataa_signal_crop (h,fs,t_start-t_rise,t_start + 1/fc);
hh = detrend (hh);

% step response:
[s,ts] = mataa_IR_to_SR (hh,th);

% SPL response:
if isempty(res)
	[mag,phase,f,unit_mag] = mataa_IR_to_FR (hh,fs,[],unit);
else
	[mag,phase,f,unit_mag] = mataa_IR_to_FR (hh,fs,1/res,unit);
end


figure(1)
plot (ts,s,style);
title ('Step response')
hold on

figure(2)
semilogx (f,mag,style)
% axis ([fL fH -30 5])
grid on
title ('SPL response')
hold on

% always save to "LastMeasurement.mat":
save ('-V7','LastMeasurementIMUPLSERESPONSE.mat','h','t','unit','fL','fH','fs','T','calfile','loopback','U0rms');

% Ask to save file:
x = input ('Do you want to save raw data (impulse response) to a file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.mat','Choose file to save raw data...');
	if ischar(fn)
		info = input ('Enter data description: ','s')
		save ('-V7',fn,'h','t','unit','fL','fH','fs','T','calfile','loopback','U0rms','info');
		disp (sprintf('Saved impulse response data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end
