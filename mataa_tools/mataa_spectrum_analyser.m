function mataa_spectrum_analyser( chan_out, chan_in, fx, fs, N_len, N_avg )

% function mataa_spectrum_analyser( chan_out, chan_in, fx, fs, N_len, N_avg )
%
% Real-time spectrum analyser (PlayRec only). THIS IS WORK IN PROGRESS!!!
% 
% EXAMPLE:
% > mataa_spectrum_analyser( 1, 1, 1000.0, 44100, 1024, 5 )

N_len = 2^(round(log2(N_len)));

pageBufCount = 5;   %number of PlayRec pages of buffering

fftSize = N_len * 2;

if((ndims(chan_out)~=2) || (size(chan_out, 1)~=1))
    error ('mataa_spectrum_analyser: chan_out must be a row vector');
end
if((ndims(chan_in)~=2) || (size(chan_in, 1)~=1))
    error ('mataa_spectrum_analyser: chan_in must be a row vector');
end

%Test if current initialisation is ok
output_ID = mataa_settings ('audio_PlayRec_OutputDevice');
input_ID  = mataa_settings ('audio_PlayRec_InputDevice');
if ~mataa_audio_init_playrec(fs, output_ID, input_ID, length(chan_out), length(chan_in));
	error ('mataa_spectrum_analyser: could not init PlayRec as needed.')
end

%Clear all previous pages
playrec('delPage');

% init plots:
fig = figure;
timeAxes = subplot(2,1,1);
set(timeAxes, 'box', 'on', 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'linear', 'yscale', 'linear', 'xlim', [1 N_len], 'ylim', [-1, 1]);
for i=1:length(chan_in)
    timeLine(i) = line('XData', 1:N_len,'YData', ones(1, N_len));
end
fftAxes  = subplot(2,1,2);
set(fftAxes, 'box', 'on', 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'log', 'xlim', [10 fs/2], 'ylim', [1E-6, 100]);
for i=1:length(chan_in)
    fftLine(i) = line('XData', (0:(fftSize/2))*fs/fftSize,'YData', ones(1, fftSize/2 + 1));
end

drawnow;

recSampleBuffer = zeros(fftSize, length(chan_in));

% Create vector to act as FIFO for page numbers
pageNumList = repmat(-1, [1 pageBufCount]);

firstTimeThrough = true;

window = hanning(fftSize);

disp('SPECTRUM ANALYSER IS RUNNING -- CLOSE PLOT WINDOW TO STOP!')

while ishandle(fig)
    pageNumList = [pageNumList playrec('rec', N_len, chan_in)];

    if(firstTimeThrough)
        %This is the first time through so reset the skipped sample count
        playrec('resetSkippedSampleCount');
        firstTimeThrough = false;
    else
        if(playrec('getSkippedSampleCount'))
            fprintf('%d samples skipped!!\n', playrec('getSkippedSampleCount'));
            %return
            %Let the code recover and then reset the count
            firstTimeThrough = true;
        end
    end
    playrec('block', pageNumList(1));
   
    lastRecording = playrec('getRec', pageNumList(1));
    if(~isempty(lastRecording))
        %very basic processing - windowing would produce a better output
        recSampleBuffer = [recSampleBuffer(length(lastRecording) + 1:end, :); lastRecording];

	% do some processing to give better spectrum:
	%%%% recSampleBuffer = recSampleBuffer - mean (recSampleBuffer);
	recSampleBuffer = detrend(recSampleBuffer,1);
	recSampleBuffer = recSampleBuffer .* window;

        recFFT = fft(recSampleBuffer)';

	% subplot(2,1,1)
        for i=1:length(chan_in)
                set(timeLine(i), 'YData', lastRecording(:,i));
        end
	% subplot(2,1,2)
        for i=1:length(chan_in)
		%% set(fftLine(i), 'YData', 20*log10(abs(recFFT(i, 1:fftSize/2 + 1))));
		set(fftLine(i), 'YData', abs(recFFT(i, 1:fftSize/2 + 1)));
        end
    end

    drawnow;
    
    playrec('delPage', pageNumList(1));
    %pop page number from FIFO
    pageNumList = pageNumList(2:end);
end
    
%delete all pages now loop has finished
playrec('delPage');
