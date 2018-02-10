function [HD,fHD,THD,THDN,L,f,unit] = mataa_measure_HD_noise ( f0,T,fs,N_h,latency,cal,amplitude,unit,window,fLow,fHigh,N_avg );

% function [HD,fHD,THD,THDN,L,f,unit] = mataa_measure_HD_noise ( f0,T,fs,N_h,latency,cal,amplitude,unit,window,fLow,fHigh,N_avg );
%
% DESCRIPTION:
% Measure harmonic distortion and total harmonic distortion plus noise (THD+N). If necessary, the fundamental frequency (f0) is adjusted to match the center of the closest FFT bin to avoid smearing of the spectrum.
% 
% INPUT:
% fi: fundamental frequency (Hz).
% T: length of sine signal in seconds.
% fs: sampling frequency in Hz
% N_h: number of harmonics to consider (including the fundamental)
% latency (optional): see mataa_measure_signal_response (default: latency = [])
% cal (optional): calibration data for data calibration (see mataa_signal_calibrate for details).
% amplitude and unit (optional): amplitude and unit of test signal at DUT input (see mataa_measure_signal_response). Note that the 'unit' controls the amplitude of the analog signal at the DUT input. Default: amplitude = 1, unit = 'digital'.
% window (optional): window function to be applied to the DUT response before calculating the spectrum (default: window = 'none'). See also mataa_signal_window(...). If the window function requires additional parameter, then window can be given as a struct with three fields corresponding to the mataa_signal_window(...) arguments as follows:
%	window.name = 'window' input argument of mataa_signal_window(...)
%	window.par  = 'par' input argument of mataa_signal_window(...)
% 	window.len  = 'len' input argument of mataa_signal_window(...) 
% fLow,fHigh (optional): frequency bandwith of analysis (default: fLow = [], fHigh = []):
%	- If fLow is not empty, only spectral data at frequencies larger or equal to fLow are used for the analysis.
%	- If fHIgh is not empty, only spectral data at frequencies lower or equal to fHigh are used for the analysis.
% N_avg (optional): number of averages (integer, default: N_avg = 1). If N_avg > 1, the measurement is repeated N_avg times, and the mean result is returned. This is useful to reduce the noise floor.
%
% OUTPUT:
% HD: amplitudes of the fundamental and harmonics (RMS value, length(HD) = N_h).
% fHD: frequency values of the fundamental and harmonics (Hz)
% THD: total harmonic distortion ratio (THD = sqrt(sum(HD(2:end).^2))/HD(1), following the AD convention for normalisation
% THDN: THD + noise (THD+N) ratio. THD+N ratio = RMS level of the measured distortion plus noise (with the fundamental removed) divided by the level of the fundamental (following the AD convention).
% L and fL: full spectrum (see mataa_measure_sine_distortion)
% unit: unit of data in HD and L.
%
% NOTE:
% The THD ratio and the THD+N ratio are normalised to the level of the fundamental (as described in [1,2]). The alternative convention of normalising to the full signal including harmonics or noise (as used by Audio Precision, for example) is discouraged, because it may cause errors and misinterpretation [1,2].
%
% REFERENCES:
% [1] "On the Definition of Total Harmonic Distortion and Its Effect on Measurement Interpretation", Doron Shmilovitz, IEEE TRANSACTIONS ON POWER DELIVERY, VOL. 20, NO. 1, JANUARY 2005, http://www.eng.tau.ac.il/~shmilo/10.pdf
% [2] "Understand SINAD, ENOB, SNR, THD, THD + N, and SFDR so You Don't Get Lost in the Noise Floor", Walt Kester, Analog Devices MT-003, http://www.analog.com/media/en/training-seminars/tutorials/MT-003.pdf
%
% EXAMPLE-1 (harmonic distorion + noise analysis with 1 kHz fundamental, 1 second test signal, 44.1 kHz sampling rate, includ 10 peaks in analysis (fundamental + 9 harmonics):
% [HD,fHD,THD,THDN,L,fL,unit] = mataa_measure_HD_noise ( 1000,1,44100,10,0.2 );
% semilogy (fL,L/sqrt(2),'k-' , fHD,HD/sqrt(2),'ro' );
% ylabel ('Amplitude (uncal.)')
% xlabel ('Frequency (Hz)');
% 
% EXAMPLE-2 (like EXAMPLE-1, but with calibrated 3 mV test signal amplitude, Hann window, bandwith-limit 100 to 10500 Hz, 5 averages)
% [HD,fHD,THD,THDN,L,fL,unit] = mataa_measure_HD_noise ( 1000,1,44100,10,0.2,'MB_ELECTRONIC-DIRECT_CHAIN.txt',0.003,'V','hann',100,10500,5 );
% semilogy ( fL,L/sqrt(2),'k-' , fHD,HD/sqrt(2),'ro' )
% ylabel (sprintf('Amplitude (%s-RMS)',unit))
% xlabel ('Frequency (Hz)');
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

warning ('mataa_measure_HD_noise: this function is under development and needs more testing. Please use with care!')

% check arguments:
if N_h < 2
	error ('mataa_measure_HD_noise: N_h must be 2 or more.')
end

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
if ~exist('window','var')
	window = 'none';
end
if ~exist ('fLow','var')
	fLow = [];
else
	if fLow > f0
		error ('mataa_measure_HD_noise: fLow > f0.')
	end
end
if ~exist ('fHigh','var')
	fHigh = [];
else
	if fHigh < f0
		error ('mataa_measure_HD_noise: fHigh < f0.')
	end
end
if ~exist ('N_avg','var')
	N_avg = 1;
end

% init HD:
HD = fHD = repmat (NA,1,N_h);

% check if f0 matches with FFT bins, and adjust if necessary:
t = [0:round(T*fs)-1]/fs;
ff = mataa_t_to_f(t(:));
[v,k] = min(abs(ff-f0));
if v > 1E-10
	disp(sprintf('mataa_measure_HD_noise: adjusting fundamental frequency (%.3f Hz) to next FFT bin (%.3f Hz).',f0,ff(k)));
	f0 = ff(k);
end

% measure DUT response to sine signal and determine Fouries spectrum:
[L,f,f0,L0,unit] = mataa_measure_sine_distortion (f0,T,fs,latency,cal,amplitude,unit,window,N_avg);
if ~isempty(fLow)
	k = find (f >= fLow);
	f = f(k);
	L = L(k);
end
if ~isempty(fHigh)
	k = find (f <= fHigh);
	f = f(k);
	L = L(k);
end

% determine levels of harmonics:
i = 1;
while i <= N_h
	ff = i*f0;
	if ff <= max(f)
		fHD(i) = ff;
		j = find (fHD(i) == f);
		HD(i) = L(j);	
		i = i+1;	
	else
		i = N_h + 1;
	end
end

% determine THD (without noise):
kTHD = find (~isna(HD)); kTHD(1) = []; % index to the harmonics
THD = sqrt(sum(HD(kTHD).^2))/HD(1);

% determine THD+N (spectrum without fundamental):

df = 50*(f(2)-f(1));
if df < 1
	df = 1;
elseif df > f0/2
	df = f0/2;
end
kn = find (f<f0-df | f>f0+df ); % index to "harmonics+noise" data (everything that is not close to the fundametal frequency)
Ln = L(kn);
THDN = sqrt ( sum((Ln/HD(1)).^2) ); % RMS of L without the contributon from the fundamental, normalised to the fundamental
% SEE: "Understand SINAD, ENOB, SNR, THD, THD + N, and SFDR so You Don't Get Lost in the Noise Floor" by Walt Kester)
% NOTE: Audio Precision uses different convention (nomralise by total RMS of full spectrum, not the fundamental)

% semilogy (f,L+eps,'k-' , f(kn),Ln+eps,'g-' , fHD,HD,'ro')

