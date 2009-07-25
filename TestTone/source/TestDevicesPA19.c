/** @file pa_devs.c
	@ingroup test_src
    @brief List available devices, including device information.
	@author Phil Burk http://www.softsynth.com

    @note Define PA_NO_ASIO to compile this code on Windows without
        ASIO support.
*/
/*
 * $Id: pa_devs.c 1308 2007-12-26 02:45:15Z gordon_gidluck $
 *
 * This program uses the PortAudio Portable Audio Library.
 * For more information see: http://www.portaudio.com
 * Copyright (c) 1999-2000 Ross Bencina and Phil Burk
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 * The text above constitutes the entire PortAudio license; however, 
 * the PortAudio community also makes the following non-binding requests:
 *
 * Any person wishing to distribute modifications to the Software is
 * requested to send the modifications to the original developer so that
 * they can be incorporated into the canonical version. It is also 
 * requested that these non-binding requests be included along with the 
 * license above.
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
int main(void);
int main(void)
{
    int     i, numDevices, defaultInputFound, defaultOutputFound;
    const   PaDeviceInfo *deviceInfo;
    PaStreamParameters inputParameters, outputParameters;
    PaError err;

    
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
