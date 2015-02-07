function mataa_plot_defaults

% function mataa_plot_defaults
%
% DESCRIPTION:
% In earlier version of MATAA, this function sets default gnuplot state for MATAA plots in Octave. With the current version of MATAA, this function has no effect.
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA
%
% HISTORY:
% 26. December 2007 (Matthias Brennwald): commented out all commands so they have no effect anymore. Leave setting of plotting options to the user.
% first version: 7. November 2006, Matthias Brennwald

%%%% if exist('OCTAVE_VERSION')
%%%%     % do Octave specific stuff here
%%%% else
%%%%     % do Matlab specific stuff here
%%%%     %%% fh = gcf;
%%%%     %%% p = get(fh,'Position');
%%%%     %%% if p([3,4]) == [560   420];
%%%%     %%%     % make plots somewhat smaller than default
%%%%     %%%     p([3,4]) = [450   280];
%%%%     %%%     set(fh,'Position',p); 
%%%%     %%% end
%%%%     %%% set(fh,'PaperPositionMode','auto'); % use same plot size for saving files as for plotting on screen
%%%% end

%%%% if mataa_settings('plotHoldState')
%%%%     hold on
%%%% end
%%%% 
%%%% % otherwise leave the plot state as it is (the user may have typed 'hold on' or something
