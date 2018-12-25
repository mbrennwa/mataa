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

% test signal
if ~exist('sig','var')
	sig = -1;
	while isempty(find(sig==[1:3]))
		sig = menu ('Choose test signal', {'Sine sweep','MLS','Pink noise'});
	end
	switch sig
		case 1
			sig = 'sweep';
		case 2
			sig = 'MLS';
		case 3
			sig = 'pinknoise';
	end
end
disp (sprintf('Test signal sig = %s',sig))

switch (sig)

	% sine sweep:
	case 'sweep'
		if ~exist('T','var')
			T = input ('Sine sweep duration (s): ');
		end

		if ~exist('fL','var')
			fL = input ('Sine sweep start frequency (Hz): ');
		end
		fL = max([1/T,fL]);
		disp (sprintf('Sine sweep start frequency fL = %g Hz',fL))

		if ~exist('fH','var')
			fH = input ('Sine sweep end frequency (Hz): ')
		end
		fH = min([fs/2,fH]);
		disp (sprintf('Sine sweep end frequency fH = %g Hz',fH))

		s0 = mataa_signal_generator ('sweep',fs,T,[fL fH]); % log-sweep from fL to fH


	% MLS
	case 'MLS'
		if ~exist('nMLS','var')
			nMLS = input ('Number of MLS taps n (MLS length = 2^(n-1)): ');
		end
		s0 = mataa_signal_generator ('MLS',fs,0,nMLS); % MLS of length 2^(n-1)
		fH = fL = [];
		T = 2^(nMLS-1) / fs; % length of signal

	% Pink noise:
	case 'pinknoise'
		if ~exist('T','var')
			T = input ('Sine sweep duration (s): ')
		end
		s0 = mataa_signal_generator ('pink',fs,T); % pink noise sequence of length T
		fH = fL = [];
end

disp (sprintf('Test signal length T = %g s',T))

% Set RMS value of test signal:
if ~exist('U0rms','var')
	U0rms = input ('Test signal amplitude (V-RMS): ');
end
disp (sprintf('Test signal amplitude U0rms = %g V-RMS',U0rms))
s0 = s0 * U0rms/sqrt(sum(s0.^2)/length(s0)); % normalise to desired RMS level


% Number of repeats for averaging:
if ~exist('Nrepeat','var')
	Nrepeat = input ('Number of repeats for averaging (leave empty for Nrepeat = 1): ');
end
if isempty (Nrepeat)
	Nrepeat = 1;
end
Nrepeat = round(Nrepeat);
if Nrepeat == 1
	disp ('Singe measurement / no averaging, Nrepeat = 1.');
else
	disp (sprintf('Number of repeated measurements for averaging Nrepeat = %i',Nrepeat))
end

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
	fc = input ('Lower cut-off frequency for SPL display (--> gate time) (Hz): ');
end
if isempty (fc)
	disp ('Time gating turned off, fc = [].')
else
	disp (sprintf('Time-domain gating / cut-off frequency fc = %g Hz',fc))
end

% SPL smoothing / resolution:
if ~exist('res','var')
	res = input ('SPL response smoothing (octave-fraction, leave empty for no smoothing): ');
end
if res <= 0
	res = [];
end
if isempty(res)
	disp ('SPL response smoothing turned off, res = [].')
else
	disp (sprintf('SPL response smoothing 1/res = 1/%i octave',res))
end

% Plot color:
if ~exist('col','var')
	col = input ('Plot color (char: k, r, g, b, c, m, y): ','s');
end
if isempty(cell2mat(strfind(col,{'k', 'r', 'g', 'b', 'c', 'm', 'y'})))
	col = 'r';
end
disp (sprintf('Plot color col = %s',col))
style = sprintf('%s-',col);


% Ready? Input ok?
input ('Ready to start? Press ENTER...');

% measure impulse response:
[h,t,unit] = mataa_measure_IR (s0,fs,Nrepeat,0.2,loopback,calfile,'V');

% time gating:
[t_start,t_rise] = mataa_guess_IR_start (h,fs);
if isempty(fc)
	[hh,th] = mataa_signal_crop (h,fs,t_start-t_rise,t(end));
else
	[hh,th] = mataa_signal_crop (h,fs,t_start-t_rise,t_start + 1/fc);
end
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
save ('-V7','LastMeasurementIMUPLSERESPONSE.mat','h','t','unit','fL','fH','fs','T','calfile','loopback','U0rms','sig','Nrepeat');

% Ask to save file:
x = input ('Do you want to save raw data (impulse response) to a file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.mat','Choose file to save raw data...');
	if ischar(fn)
		info = input ('Enter data description: ','s')
		save ('-V7',fn,'h','t','unit','fL','fH','fs','T','calfile','loopback','U0rms','sig','Nrepeat','info');
		disp (sprintf('Saved impulse response data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end
