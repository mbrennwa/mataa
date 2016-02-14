function [mag,phase,f,f0] = mataa_IR_to_FR_LFextend (h,t,t0,smooth_interval_H,smooth_interval_L,unit);

% function [mag,phase,f,f0] = mataa_IR_to_FR_LFextend (h,t,t0,smooth_interval_H,smooth_interval_L,unit);
%
% DESCRIPTION:
% Calculate frequency response (magnitude in dB and phase in degrees) of a system with impulse response h(t). Calculate anechoic response for 'high' frequencies (f >= f0) by gating out reflections occurring at times t > t0 (by discarding data beyond t > t0). Expand this with full response at lower frequencies (f < f0)
%
% INPUT:
% h: impulse response (in volts)
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% t0: delay of (first) echo relative to start of impulse response data
% smooth_interval_H and smooth_interval_L (optional): if specified, the frequency response is smoothed over the octave interval smooth_interval (separate values for high / H and low / L frequency part).
%
% OUTPUT:
% mag: magnitude of frequency response (in dB). If unit of h is 'Pa' (Pascal), then mag is referenced to 20 microPa (standard reference sound pressure level).
% phase: phase of frequency response (in degrees). This is the TOTAL phase including the 'excess phase' due to (possible) time delay of h(h). phase is unwrapped (i.e. it is not limited to +/-180 degrees, and there are no discontinuities at +/- 180 deg.)
% f: frequency coordinates of mag and phase
% f0: cut-off frequency of anechoic part
%
% EXAMPLE:
% [h,t] = mataa_IR_demo ('FE108');
% t0 = t(end);
% h = [ h ; 0.1*h ; repmat(0,length(h)*3,1) ];% construct impulse response with 'fake' echo at t > t0
% t = linspace (0,5*t0, length(h))';
% [mag,phase,f,f0] = mataa_IR_to_FR_LFextend (h,t,t0,[],1/4);
% subplot (2,1,1); plot (t,h);
% subplot (2,1,2); semilogx (f,mag)

if ~exist ('unit','var')
	unit = 'unknown';
end

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

if ~exist("smooth_interval_L","var")
	smooth_interval_L = [];
end

if ~exist("smooth_interval_H","var")
	smooth_interval_H = [];
end

h = h(:); % make sure h is column vector

% calculate anechoic part:
k = find (t < t0);
[m,p,f] = mataa_IR_to_FR (detrend(h(k)),t(k),smooth_interval_H,unit);
f0 = min(f);

% calculate full response (incl. echoes)
[mm,pp,ff] = mataa_IR_to_FR (detrend(h),t,smooth_interval_L,unit);

% combine both parts
[mag,phase,f] = mataa_FR_extend_LF (f,m,p,ff,mm,pp,f0,2.5*f0);