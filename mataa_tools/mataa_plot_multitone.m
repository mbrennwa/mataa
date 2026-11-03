function [h_dut, h_ref] = mataa_plot_multitone (dut, ref, which)

% function [h_dut, h_ref] = mataa_plot_multitone (dut, ref, which)
%
% DESCRIPTION:
% Plot a multitone result from mataa_measure_multitone. The device is blue on the left axis. ref is optional; when given and not empty, it is red on the right axis and is drawn underneath the device. The highest point of each spectrum is at the same height, and both axes use the same number of decibels per division. Tick labels stay in each channel's own unit.
%
% INPUT:
% dut: device result struct.
% ref (optional): reference result struct. Omit it, or pass [], to draw the device only.
% which (optional): 'mean' (default) plots P_mean, 'coh' plots P_coh.
%
% OUTPUT:
% h_dut, h_ref: structs of line handles with fields spectrum, peaks, and grass. h_ref is empty when ref was omitted.
%
% EXAMPLE:
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

if nargin < 1 || ~isstruct(dut) || ~isfield(dut, 'f')
	error('mataa_plot_multitone: dut must be a result struct.');
end
if nargin < 2
	ref = [];
end
if nargin < 3 || isempty(which)
	which = 'mean';
end

[f_d, L_d, fp_d, Lp_d, fg_d, Lg_d] = __curves(dut, which);
have_ref = isstruct(ref) && isfield(ref, 'f') && ~isempty(ref.f);

figure;
h_ref = struct();
if have_ref
	[f_r, L_r, fp_r, Lp_r, fg_r, Lg_r] = __curves(ref, which);
	ax_ref = axes('YAxisLocation', 'right', 'XScale', 'log', 'Box', 'off');
	hold(ax_ref, 'on');
	h_ref = __draw(ax_ref, f_r, L_r, fp_r, Lp_r, fg_r, Lg_r, 'r');
	ylabel(ax_ref, __ylab(ref.unit));
	[span, pad, Lmax, Rmax] = __span(L_d, L_r);
	ylim(ax_ref, [Rmax - span, Rmax + pad]);
	ax_dut = axes('Position', get(ax_ref, 'Position'), 'Color', 'none', 'XScale', 'log', 'YAxisLocation', 'left', 'Box', 'off');
else
	ax_dut = axes('XScale', 'log');
	Lmax = max(L_d(isfinite(L_d)));
	span = Lmax - min(L_d(isfinite(L_d)));
	if ~(span > 0)
		span = 1;
	end
	pad = 0.03 * span;
end

hold(ax_dut, 'on');
h_dut = __draw(ax_dut, f_d, L_d, fp_d, Lp_d, fg_d, Lg_d, 'b');
xlabel(ax_dut, 'Frequency (Hz)');
ylabel(ax_dut, __ylab(dut.unit));
grid(ax_dut, 'on');

if have_ref
	ylim(ax_dut, [Lmax - span, Lmax + pad]);
	xlim(ax_ref, xlim(ax_dut));
	set(ax_ref, 'XTick', []);
else
	ylim(ax_dut, [Lmax - span, Lmax + pad]);
end

end

function [f, L, fp, Lp, fg, Lg] = __curves(r, which)
	switch lower(which)
		case 'mean'
			P = r.P_mean;
			band_P = r.band_P_mean;
		case 'coh'
			P = r.P_coh;
			band_P = r.band_P_coh;
		otherwise
			error('mataa_plot_multitone: which must be ''mean'' or ''coh''.');
	end
	f = r.f(:);
	keep = f > 0;
	if isfield(r, 'f_analyse_high') && ~isempty(r.f_analyse_high)
		keep = keep & f <= r.f_analyse_high;
	end
	f = f(keep);
	L = __db(P(keep));
	ex = r.excited(:);
	ex = ex(ex >= 1 & ex <= length(r.f));
	ex = ex(keep(ex));
	fp = r.f(ex);
	Lp = __db(P(ex));
	[fp, ix] = sort(fp);
	Lp = Lp(ix);
	fg = r.band_f(:);
	Lg = __db(band_P(:));
	ok = isfinite(Lg);
	fg = fg(ok);
	Lg = Lg(ok);
end

function L = __db(P)
	P = P(:);
	L = NaN(size(P));
	ok = P > 0;
	L(ok) = 10 * log10(P(ok));
end

function lab = __ylab(unit)
	if isempty(unit)
		unit = '1';
	end
	lab = sprintf('%s (dB re 1)', unit);
end

function h = __draw(ax, f, L, fp, Lp, fg, Lg, color)
	h.spectrum = line(ax, f, L, 'Color', color, 'LineStyle', '-');
	h.grass = line(ax, fg, Lg, 'Color', color, 'LineStyle', '--', 'LineWidth', 1.5);
	h.peaks = line(ax, fp, Lp, 'Color', color, 'LineStyle', '-', 'LineWidth', 1.5);
end

function [span, pad, Lmax, Rmax] = __span(L_d, L_r)
	Ld = L_d(isfinite(L_d));
	Lr = L_r(isfinite(L_r));
	Lmax = max(Ld);
	Rmax = max(Lr);
	dL = Lmax - min(Ld);
	dR = Rmax - min(Lr);
	span = max(dL, dR);
	if ~(span > 0)
		span = 1;
	end
	pad = 0.03 * span;
end
