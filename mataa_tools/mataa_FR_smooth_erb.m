function [mag_s, phase_s] = mataa_FR_smooth_erb(f, mag, phase, width_erb)


% function [mag_s, phase_s] = mataa_FR_smooth_erb(f, mag, phase, width_erb);
%
% DESCRIPTION:
% Smooth frequency response in ERB bands (frequency bands that match human auditory resolution).
%
% Uses Glasberg & Moore ERB-rate scale:
%   erbRate(f)  = 21.4 * log10(1 + 4.37e-3*f)
%   invErbRate  = (10^(erb/21.4)-1)/4.37e-3
%
% INPUT:
% f           : frequency vector [Hz], arbitrary spacing, must be >0
% mag         : magnitude in dB
% phase       : phase in degrees
% width_erb   : smoothing width in ERB-rate units (typical 0.3...3)
%
% OUTPUT:
% mag_s         : smoothed magnitude in dB, evaluated at original f
% phase_s     : smoothed phase in degrees, evaluated at original f (wrapped to [-180,180])
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
% Copyright (C) 2025 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

  if (width_erb <= 0)
	mag_s = mag; phase_s = phase; return;
  end

  erb_step  = 0.05;

  % ---- input checks / reshape ----
  f = f(:);
  mag = mag(:);
  phase = phase(:);

  if any(f <= 0), error('All frequency values must be > 0 Hz.'); end
  if ~(numel(f)==numel(mag) && numel(f)==numel(phase))
    error('f, mag, and phase must have the same length.');
  end

  % sort by frequency (important for interpolation)
  [f, idx] = sort(f);
  mag = mag(idx);
  phase = phase(idx);
  
  % ---- build complex response from mag/phase ----
  mag_lin = 10.^(mag/20);
  ph_rad = deg2rad(phase);
  H = mag_lin .* exp(1i*ph_rad);

  % ---- Hz -> ERB-rate ----
  erb = erb_rate(f);

  % ---- uniform ERB grid ----
  erb_min = erb(1);
  erb_max = erb(end);
  erb_g = (erb_min:erb_step:erb_max).';

  % ---- interpolate complex response onto ERB grid ----
  % Interpolate real & imag separately (robust for arbitrary samples)
  Hr_g = interp1(erb, real(H), erb_g, 'linear', 'extrap');
  Hi_g = interp1(erb, imag(H), erb_g, 'linear', 'extrap');
  H_g = Hr_g + 1i*Hi_g;

  % ---- ERB-domain smoothing (Gaussian) ----
  % Gaussian sigma chosen so that FWHM = width_erb
  % FWHM = 2*sqrt(2*ln(2)) * sigma  => sigma = FWHM / 2.3548
  sigma = width_erb / 2.354820045;
  % kernel support: +/- 4 sigma (enough for practical purposes)
  half_width = max(1, ceil((4*sigma)/erb_step));
  x = (-half_width:half_width).' * erb_step;
  g = exp(-(x.^2)/(2*sigma^2));
  g = g / sum(g);

  % pad to reduce edge shrinkage
  H_pad = [repmat(H_g(1), half_width, 1); H_g; repmat(H_g(end), half_width, 1)];
  H_sm_pad = conv(H_pad, g, 'same');
  H_sm_g = H_sm_pad(half_width+1:end-half_width);

  % ---- back to original f grid ----
  Hr_s = interp1(erb_g, real(H_sm_g), erb, 'linear', 'extrap');
  Hi_s = interp1(erb_g, imag(H_sm_g), erb, 'linear', 'extrap');
  H_s_sorted = Hr_s + 1i*Hi_s;

  % magnitude and phase
  mag_s_sorted = 20*log10(abs(H_s_sorted) + eps);
  phase_s_sorted = unwrap(angle(H_s_sorted));     % radians, continuous
  phase_s_sorted = phase_s_sorted * 180/pi;       % degrees


  % unsort to original order
  inv_idx = zeros(size(idx));
  inv_idx(idx) = 1:numel(idx);
  mag_s = mag_s_sorted(inv_idx);
  phase_s = phase_s_sorted(inv_idx);
end

% ---------- helpers ----------
function e = erb_rate(f)
  e = 21.4 .* log10(1 + 4.37e-3 .* f);
end

function f = inv_erb_rate(e)
  f = (10.^(e./21.4) - 1) ./ 4.37e-3;
end
