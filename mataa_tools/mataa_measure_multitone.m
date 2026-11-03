function [dut, ref] = mataa_measure_multitone (setup, f1, f2, fs, level, unit, latency, cal_DUT, cal_REF, param)

% function [dut, ref] = mataa_measure_multitone (setup, f1, f2, fs, level, unit, latency, cal_DUT, cal_REF, param)
%
% DESCRIPTION:
% One-shot sparse multitone distortion measurement. The function builds the stimulus, plays one settling period and then the analysed periods, and returns a result struct for the device. When cal_REF is given, the reference channel is recorded in the same take and returned the same way. The reference is not subtracted from the device and is not used as a divisor.
%
% INPUT:
% setup: 'acoustic', 'electronic', or 'user'.
%   'acoustic': 6 tones/octave, equal amplitudes, IEC phases.
%   'electronic': Phi12r tones inside [f1, f2], equal amplitudes, IEC phases.
%   'user': param is required.
% f1, f2: lowest and highest stimulus frequencies (Hz).
% fs: sampling rate (Hz).
% level: RMS of one stimulus period at the DUT input, in unit.
% unit: unit of level, passed to mataa_measure_signal_response ('digital', 'V', ...).
% latency (optional): see mataa_measure_signal_response. Default [].
% cal_DUT (optional): calibration of the device channel. A file name or a cal struct. Default [].
% cal_REF (optional): calibration of the reference channel. Empty skips that channel, warns, and returns an empty ref. A single device calibration is not copied onto the reference.
% param (optional): struct of generator and acquisition overrides. For setup 'user' it is required. Fields:
%   spacing ('octave' or 'phi12r'), tones_per_octave, shaping ('equal', 'eia426b', or an Hz/dB matrix), phases ('iec' or a vector),
%   N (samples per period; default fs, so the period is 1 s), n_settle (default 1), n_analyse (default 8), f_analyse_high (default min(fs/2, 2*f2)).
%   'eia426b' is the ARTA import used to match published loudspeaker tests, not the normative EIA-426-B table.
%
% OUTPUT:
% dut, ref: one struct per channel. ref is empty when cal_REF is empty. Fields:
%   f, P_mean, P_coh: frequency (Hz) and one-sided mean-square spectra. The sum of each spectrum equals the mean square of its waveform.
%   excited: indices into f of the stimulus bins inside the analysis band.
%   band_f, band_P_mean, band_P_coh: 1/6-octave centres and the unexcited power in each band.
%   D_mtn_mean, D_mtn_coh: sqrt(unexcited power / excited power) inside the analysis band.
%   unit, rms, peak: unit and the level of the analysed samples.
%   f_analyse_high: upper analysis frequency (Hz).
%   stimulus: tone grid, amplitudes, phases, RMS, peak and crest factor of the unit-RMS period, plus the level applied at the DUT input.
%   lag, rho: lag (samples) and normalised correlation of each analysed period against the first.
%   leakage: fraction of tone-bin power found in the neighbouring bins of one rectangular FFT of the whole analysed block.
% A non-zero lag produces a warning. Samples are not shifted or resampled.
%
% EXAMPLE:
% > [dut, ref] = mataa_measure_multitone ('acoustic', 1000, 20000, 48000, 0.1, 'digital');
% > [h_dut, h_ref] = mataa_plot_multitone (dut, ref);
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
% Copyright (C) 2026 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if nargin < 6
	error('mataa_measure_multitone: need setup, f1, f2, fs, level, and unit.');
end
if ~exist('latency', 'var')
	latency = [];
end
if ~exist('cal_DUT', 'var')
	cal_DUT = [];
end
if ~exist('cal_REF', 'var')
	cal_REF = [];
end
if ~exist('param', 'var')
	param = [];
end

setup = lower(setup);
switch setup
	case 'acoustic'
		p = struct('spacing', 'octave', 'tones_per_octave', 6, 'shaping', 'equal', 'phases', 'iec');
	case 'electronic'
		p = struct('spacing', 'phi12r', 'shaping', 'equal', 'phases', 'iec');
	case 'user'
		if ~isstruct(param)
			error('mataa_measure_multitone: setup ''user'' requires param.');
		end
		p = struct();
	otherwise
		error('mataa_measure_multitone: setup must be ''acoustic'', ''electronic'', or ''user''.');
end

p.n_settle = 1;
p.n_analyse = 8;
if isstruct(param)
	fn = fieldnames(param);
	for i = 1:length(fn)
		p.(fn{i}) = param.(fn{i});
	end
end
if isfield(p, 'spacing') && ischar(p.spacing) && strcmpi(p.spacing, 'nid')
	error('mataa_measure_multitone: NID spacing is not implemented.');
end
if ~(level > 0)
	error('mataa_measure_multitone: level must be a positive RMS.');
end

if ~isfield(p, 'N') || isempty(p.N)
	p.N = fs;
end
N = round(p.N);
if N < 2
	error('mataa_measure_multitone: N must be at least 2.');
end
if p.n_settle < 0 || p.n_analyse < 1
	error('mataa_measure_multitone: n_settle must be >= 0 and n_analyse must be >= 1.');
end
if ~isfield(p, 'f_analyse_high') || isempty(p.f_analyse_high)
	f_high = min(fs/2, 2 * f2);
else
	f_high = p.f_analyse_high;
end

gen = p;
gen.f1 = f1;
gen.f2 = f2;
T = N / fs;
[period, ~, info] = mataa_signal_generator('multitone', fs, T, gen);
period = period * level;
if strcmpi(unit, 'digital') && max(abs(period)) > 1
	error('mataa_measure_multitone: the digital waveform exceeds full scale. Lower level.');
end
info.level = level;
info.level_unit = unit;
info.peak_at_dut = max(abs(period));
info.setup = setup;

played = repmat(period, p.n_settle + p.n_analyse, 1);
have_ref = __cal_present(cal_REF);
if ~have_ref
	warning('mataa_measure_multitone: cal_REF is empty. The loopback channel is not recorded, and ref is empty.');
	channels = mataa_settings('channel_DUT');
	X0 = played;
	cal = __load_cal(cal_DUT);
else
	channels = [mataa_settings('channel_DUT') mataa_settings('channel_REF')];
	X0 = [played played];
	cal = { __load_cal(cal_DUT), __load_cal(cal_REF) };
end

[y, ~, ~, y_unit] = mataa_measure_signal_response(X0, fs, latency, 1, channels, cal, unit);

dut = __analyse_channel(y(:, 1), played, period, info, fs, f_high, __unit_of(y_unit, 1), p.n_settle, p.n_analyse, 'device');
if have_ref
	ref = __analyse_channel(y(:, 2), played, period, info, fs, f_high, __unit_of(y_unit, 2), p.n_settle, p.n_analyse, 'reference');
else
	ref = struct();
end

end

function present = __cal_present(cal)
	present = true;
	if isempty(cal)
		present = false;
	elseif ischar(cal) && isempty(cal)
		present = false;
	end
end

function cal = __load_cal(cal)
	if ischar(cal) && ~isempty(cal)
		cal = mataa_load_calibration(cal);
	end
end

function u = __unit_of(y_unit, k)
	if iscell(y_unit)
		u = y_unit{k};
	else
		u = y_unit;
	end
	if isempty(u)
		u = '';
	end
end

function r = __analyse_channel(y, played, period, info, fs, f_high, unit, n_settle, n_analyse, name)

	y = y(:);
	N = length(period);
	i0 = __xcorr_onset(y, played);
	if n_settle > 0
		i_after = i0 + n_settle * N;
		if i_after > length(y)
			error('mataa_measure_multitone: the settling period ends past the recording.');
		end
		i_rel = __xcorr_onset(y(i_after:end), repmat(period, n_analyse, 1));
		i1 = i_after - 1 + i_rel;
	else
		i1 = i0;
	end
	i2 = i1 + n_analyse * N - 1;
	if i1 < 1 || i2 > length(y)
		error('mataa_measure_multitone: the analysed periods do not lie inside the recording.');
	end
	block = y(i1:i2);
	periods = reshape(block, N, n_analyse);

	lag = zeros(1, n_analyse);
	rho = zeros(1, n_analyse);
	lag(1) = 0;
	rho(1) = 1;
	for m = 2:n_analyse
		[lag(m), rho(m)] = __period_lag(periods(:, 1), periods(:, m));
	end
	if any(lag ~= 0)
		warning(sprintf('mataa_measure_multitone: a %s period is shifted relative to the first (lags %s). The samples were left as recorded.', name, mat2str(lag)));
	end

	P = zeros(floor(N/2) + 1, n_analyse);
	for m = 1:n_analyse
		[P(:, m), f] = __ms_spectrum(periods(:, m), fs);
	end
	P_mean = mean(P, 2);
	[P_coh, ~] = __ms_spectrum(mean(periods, 2), fs);

	in_band = f > 0 & f <= f_high;
	excited = false(size(f));
	for i = 1:length(info.bin)
		idx = info.bin(i) + 1;
		if idx >= 1 && idx <= length(f)
			excited(idx) = true;
		end
	end
	excited_band = excited & in_band;
	unexcited_band = in_band & ~excited;
	if ~any(excited_band)
		error('mataa_measure_multitone: no stimulus tones lie inside the analysis band.');
	end
	D_mtn_mean = sqrt(sum(P_mean(unexcited_band)) / sum(P_mean(excited_band)));
	D_mtn_coh = sqrt(sum(P_coh(unexcited_band)) / sum(P_coh(excited_band)));

	[band_f, band_P_mean] = __sixth_octave(f, P_mean, unexcited_band, f_high);
	[~, band_P_coh] = __sixth_octave(f, P_coh, unexcited_band, f_high);

	leakage = __beside_tone_leakage(block, info.bin, n_analyse);

	r = struct();
	r.f = f;
	r.P_mean = P_mean;
	r.P_coh = P_coh;
	r.excited = find(excited_band);
	r.band_f = band_f;
	r.band_P_mean = band_P_mean;
	r.band_P_coh = band_P_coh;
	r.D_mtn_mean = D_mtn_mean;
	r.D_mtn_coh = D_mtn_coh;
	r.unit = unit;
	r.rms = sqrt(mean(block .^ 2));
	r.peak = max(abs(block));
	r.f_analyse_high = f_high;
	r.stimulus = info;
	r.lag = lag;
	r.rho = rho;
	r.leakage = leakage;

end

function i0 = __xcorr_onset(y, x)
	if exist('xcorr', 'file') ~= 2
		if exist('OCTAVE_VERSION', 'builtin')
			pkg load signal;
		end
	end
	if exist('xcorr', 'file') ~= 2
		error('mataa_measure_multitone: xcorr is not available. Install the Octave signal package.');
	end
	[c, lags] = xcorr(y(:), x(:));
	[~, k] = max(abs(c));
	i0 = lags(k) + 1;
end

function [lag, rho] = __period_lag(a, b)
	[c, lags] = xcorr(b(:), a(:));
	[~, k] = max(abs(c));
	lag = lags(k);
	if lag >= 0
		bb = b(1+lag:end);
		aa = a(1:length(bb));
	else
		aa = a(1-lag:end);
		bb = b(1:length(aa));
	end
	na = norm(aa);
	nb = norm(bb);
	if na == 0 || nb == 0
		rho = 0;
	else
		rho = abs(dot(aa, bb)) / (na * nb);
	end
end

function [P, f] = __ms_spectrum(y, fs)
	y = y(:);
	N = length(y);
	S = fft(y);
	npos = floor(N/2) + 1;
	P = zeros(npos, 1);
	P(1) = abs(S(1))^2 / N^2;
	if npos > 2
		P(2:npos-1) = 2 * abs(S(2:npos-1)).^2 / N^2;
	end
	if mod(N, 2) == 0
		P(npos) = abs(S(npos))^2 / N^2;
	elseif npos > 1
		P(npos) = 2 * abs(S(npos))^2 / N^2;
	end
	f = (0:npos-1)' * (fs / N);
end

function [band_f, band_P] = __sixth_octave(f, P, unexcited, f_high)
	f_lo = min(f(f > 0));
	if isempty(f_lo)
		band_f = [];
		band_P = [];
		return
	end
	kmin = floor(6 * log2(f_lo / 1000)) - 1;
	kmax = ceil(6 * log2(f_high / 1000)) + 1;
	band_f = [];
	band_P = [];
	for k = kmin:kmax
		fc = 1000 * 2^(k / 6);
		lo = fc * 2^(-1/12);
		hi = fc * 2^(1/12);
		sel = unexcited & f >= lo & f < hi & f <= f_high;
		if any(f >= lo & f < hi & f > 0 & f <= f_high)
			band_f(end+1, 1) = fc; %#ok<AGROW>
			band_P(end+1, 1) = sum(P(sel)); %#ok<AGROW>
		end
	end
end

function leakage = __beside_tone_leakage(block, bins, n_analyse)
	S = fft(block);
	M = length(block);
	tone = 0;
	side = 0;
	for i = 1:length(bins)
		b = n_analyse * bins(i);
		idx = b + 1;
		if idx < 1 || idx > M
			continue
		end
		tone = tone + abs(S(idx))^2;
		if idx > 1
			side = side + abs(S(idx-1))^2;
		end
		if idx < M
			side = side + abs(S(idx+1))^2;
		end
	end
	if tone == 0
		leakage = NaN;
	else
		leakage = side / tone;
	end
end
