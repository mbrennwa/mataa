/*
 * This is the source code for TestDevicesPA19, which is based on PortAudio V19 (http://www.portaudio.com).
 *
 * TestDevices is part of MATAA. MATAA is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * MATAA is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with MATAA; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 * 
 * Copyright (C) 2006, 2007, 2008, 2009 Matthias S. Brennwald.
 * Contact: info@audioroot.net
 * Further information: http://www.audioroot.net/mataa.html
 */

#include <stdio.h>
#include <math.h>
#include "portaudio.h"

#ifdef WIN32
#ifndef PA_NO_ASIO
#include "pa_asio.h"
#endif
#endif

/*******************************************************************/
static void PrintSupportedStandardSampleRates(
        const PaStreamParameters *inputParameters,
        const PaStreamParameters *outputParameters )
{
    static double standardSampleRates[] = {
        8000.0, 9600.0, 11025.0, 12000.0, 16000.0, 22050.0, 24000.0, 32000.0,
        44100.0, 48000.0, 88200.0, 96000.0, 192000.0, -1 /* negative terminated  list */
    };
    int     i, printCount;
    PaError err;

    printCount = 0;
    for( i=0; standardSampleRates[i] > 0; i++ )
    {
        err = Pa_IsFormatSupported( inputParameters, outputParameters, standardSampleRates[i] );
        if( err == paFormatIsSupported )
        {
            if( printCount == 0 )
            {
                printf( "\t%8.2f", standardSampleRates[i] );
            }
            else
            {
                printf( ", %8.2f", standardSampleRates[i] );
            }
			printCount++;
        }
    }
    if( !printCount )
        printf( "None\n" );
    else
        printf( "\n" );
}
/*******************************************************************/
int main(int argc, char *argv[]);
int main(int argc, char *argv[])
{
    int     i, numDevices, defaultInputFound, defaultOutputFound;
    const   PaDeviceInfo *deviceInfo;
    PaStreamParameters inputParameters, outputParameters;
    PaError err;

    argc -=1; /* first argument is call to TestTone itself */

    if (argc > 0) {
		printf("TestDevices usage:\n");
		printf("'TestDevices' displays the properties of the default audio devices for sound input and output.\n\n");
		printf("Note: the list of supported sample rates reflects the 'standard' rates offered by the operating system or the driver software of the sound device. This is not necessarily identical to the rates supported natively by hardware itself, as the operating system or the driver software may provide automatic sample-rate conversion (e.g. Mac OS X / CoreAudio). Also, the list of supported sample rates may be incomplete, because the TestDevices program checks for 'standard' rates only. It is therefore possible that sample rates other than those listed may be used with the device.\n\n");
		printf("TestDevices is part of MATAA. MATAA is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.\n\n");
		printf("MATAA is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\n");
		printf("You should have received a copy of the GNU General Public License along with MATAA; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA\n\n");
		printf("Copyright (C) 2007, 2008, 2009 Matthias S. Brennwald.\nContact: info@audioroot.net\nFurther information: http://www.audioroot.net/mataa.html\n");
		exit(1);
	}
    
    Pa_Initialize();

    //printf( "PortAudio version number = %d\nPortAudio version text = '%s'\n", Pa_GetVersion(), Pa_GetVersionText() );

            
    numDevices = Pa_GetDeviceCount();
    if( numDevices < 0 )
    {
        printf( "ERROR: Pa_GetDeviceCount returned 0x%x\n", numDevices );
        err = numDevices;
        goto error;
    }
    
	defaultInputFound = 0;
	defaultOutputFound = 0;

    for( i=0; i<numDevices; i++ )
    {
        deviceInfo = Pa_GetDeviceInfo( i );
        //printf( "--------------------------------------- device #%d\n", i );
                
        if( i == Pa_GetDefaultInputDevice() )
        {
            defaultInputFound = 1;
			printf( "Default input device = %s\n", deviceInfo->name );
			printf( "Host API (input) = %s\n",  Pa_GetHostApiInfo( deviceInfo->hostApi )->name );
			printf( "Max input channels = %d\n", deviceInfo->maxInputChannels  );
			
			/* poll for standard sample rates */
			inputParameters.device = i;
			inputParameters.channelCount = deviceInfo->maxInputChannels;
			inputParameters.sampleFormat = paInt16;
			inputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			inputParameters.hostApiSpecificStreamInfo = NULL;
			
			outputParameters.device = i;
			outputParameters.channelCount = deviceInfo->maxOutputChannels;
			outputParameters.sampleFormat = paInt16;
			outputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			outputParameters.hostApiSpecificStreamInfo = NULL;
			
			if( inputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (input, half-duplex, 16 bit, %d channels) = ",
					   inputParameters.channelCount );
				PrintSupportedStandardSampleRates( &inputParameters, NULL );
			}
			
			if( inputParameters.channelCount > 0 && outputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (input, full-duplex, 16 bit, %d channels) = ",
					   inputParameters.channelCount, outputParameters.channelCount );
				PrintSupportedStandardSampleRates( &inputParameters, &outputParameters );
			}
		}
		
		if( i == Pa_GetDefaultOutputDevice() )
		{
			defaultOutputFound = 1;
			printf( "Default output device = %s\n", deviceInfo->name );
			printf( "Host API (output) = %s\n",  Pa_GetHostApiInfo( deviceInfo->hostApi )->name );
			printf( "Max output channels = %d\n", deviceInfo->maxOutputChannels  );
			
			/* poll for standard sample rates */
			inputParameters.device = i;
			inputParameters.channelCount = deviceInfo->maxInputChannels;
			inputParameters.sampleFormat = paInt16;
			inputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			inputParameters.hostApiSpecificStreamInfo = NULL;
			
			outputParameters.device = i;
			outputParameters.channelCount = deviceInfo->maxOutputChannels;
			outputParameters.sampleFormat = paInt16;
			outputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			outputParameters.hostApiSpecificStreamInfo = NULL;
			
			if( outputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (output, half-duplex, 16 bit, %d channels) = ",
					   outputParameters.channelCount );
				PrintSupportedStandardSampleRates( NULL, &outputParameters );
			}
			
			if( inputParameters.channelCount > 0 && outputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (output, full-duplex, 16 bit, %d channels) = ",
					   inputParameters.channelCount, outputParameters.channelCount );
				PrintSupportedStandardSampleRates( &inputParameters, &outputParameters );
			}
		}
	}

    Pa_Terminate();

    printf("----------------------------------------------\n");
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    return err;
}
