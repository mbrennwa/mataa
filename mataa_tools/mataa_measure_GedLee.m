function [Gm,tf] = mataa_measure_GedLee ( f0,T,fs,N_h,latency,cal,amplitude,unit,N_avg );

% function [Gm,tf] = mataa_measure_GedLee ( f0,T,fs,N_h,latency,cal,amplitude,unit,N_avg );
%
% DESCRIPTION:
% Measure the GedLee distortion metric. This is achieved by measuring the distortion harmonics from a sine signal to construct the transfer function of the system. The transfer function is determined from the transfer function.
% 
% INPUT:
% (see mataa_measure_HD_noise)
% 'amplitude' may be specified as a vector of different amplitude values.
%
% OUTPUT:
% Gm: GedLee metric
% tf: normalised transfer function (as used to determine Gm)
%
% REFERENCES:
% [1] "Weighting Up", Keith Howard
%
% EXAMPLE-1:
% [Gm,tf] = mataa_measure_GedLee (1000,1,44100,10,0.2);
% plot (linspace(-1,1,length(tf)),tf);
% xlabel ('Input (normalised)'); ylabel ('Output (normalised)'); title ('Transfer function')
%
% EXAMPLE-2:
% ampl = logspace(-3,0,5);
% [Gm,tf] = mataa_measure_GedLee (1000,1,44100,20,0.2,'GENERIC_CHAIN_DIRECT.txt',ampl,'V');
% semilogx (ampl/sqrt(2),Gm)
% xlabel ('Signal (V-RMS)'); ylabel ('Gm value')
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
% Copyright (C) 2018 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

warning ('mataa_measure_GedLee: this function is under development and needs more testing. Please use with care!')

% check optional arguments:
if ~exist('latency','var')
	latency = []; % use default value (best guess)
end
if ~exist('cal','var')
    cal=[];
end
if ~exist('amplitude','var')
	amplitude = 1; % use default value
end
if ~exist('unit','var')
	unit = 'digital';
end
if ~exist ('N_avg','var')
	N_avg = 1;
end

if length (amplitude) > 1

	% init Gm and tf
	Gm = tf = [];

	% measure Gm and tf for each amplitude value:
	for i = 1:length(amplitude)
		[u,v] = mataa_measure_GedLee ( f0,T,fs,N_h,latency,cal,amplitude(i),unit,N_avg );
		if i == 1
			Gm = u;
			tf = v;
		else
			Gm = [ Gm ; u ];
			tf = [ tf ; v ];
		end
	end

else

	% measure Gm and tf:

	[HD,fHD,THD,THDN,L,fL,unit] = mataa_measure_HD_noise ( f0,T,fs,N_h,latency,cal,amplitude,unit,'none',[],[],N_avg );

	% amplitudes and phase angles (normalised to fundamental):
	ampli = HD(1,:) / HD(1,1);
	phase = HD(2,:) - HD(2,1);
	k = find (~isna(ampli));
	if length(k) < N_h
		N_h = length(k);
		warning (sprintf("mataa_measure_GedLee: harmonics extend beyond Nyquist frequency! Using N_h = %i...",N_h))
		ampli = ampli(k);
		phase = phase(k);
	end

	% determine transfer function:
	Nt = 5000;
	tt = [-round(Nt/4):round(Nt/4)]/Nt / f0;
	tf = repmat (0,size(tt)); % init transfer function
	for i = 1:N_h
		tf = tf + ampli(i) * sin(2*pi*fHD(i)*tt + phase(i) );
	end
	xs = sin (2*pi*fHD(1)*tt + phase(1)); % x values (pure sine curve)
	xl = linspace (-1,1,length(tt)); % x values (linear)
	tf = interp1(xs,tf,xl,'linear','extrap'); % convert tf from tf(xs) to tf(xl)

	% calculate GedLee metric (Gm):
	dx = (xl(end)-xl(1)) / (length(xl)-1);
	Gm = sqrt( sum ( cos(xl(2:end-1)*pi/2).^2 .* (diff(diff(tf))/dx^2).^2 * dx ) );

end
