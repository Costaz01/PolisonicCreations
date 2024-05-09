/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
MIDIVelocityModifyAudioProcessor::MIDIVelocityModifyAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       )
#endif
{
    sender.connect("127.0.0.1", 57120); 
}

MIDIVelocityModifyAudioProcessor::~MIDIVelocityModifyAudioProcessor()
{
    
}

//==============================================================================
const juce::String MIDIVelocityModifyAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool MIDIVelocityModifyAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool MIDIVelocityModifyAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool MIDIVelocityModifyAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double MIDIVelocityModifyAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int MIDIVelocityModifyAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int MIDIVelocityModifyAudioProcessor::getCurrentProgram()
{
    return 0;
}

void MIDIVelocityModifyAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String MIDIVelocityModifyAudioProcessor::getProgramName (int index)
{
    return {};
}

void MIDIVelocityModifyAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void MIDIVelocityModifyAudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..
}

void MIDIVelocityModifyAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool MIDIVelocityModifyAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    // This is the place where you check if the layout is supported.
    // In this template code we only support mono or stereo.
    // Some plugin hosts, such as certain GarageBand versions, will only
    // load plugins that support stereo bus layouts.
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    // This checks if the input layout matches the output layout
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void MIDIVelocityModifyAudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    
    buffer.clear();
    juce::MidiBuffer processedMidi;
    int time;
    juce::MidiMessage m;
    for (juce::MidiBuffer::Iterator i (midiMessages); i.getNextEvent (m, time);)
    {
        if (m.isNoteOn())
        {
            freq = (float) juce::MidiMessage::getMidiNoteInHertz (m.getNoteNumber());
            sender.send("/FMSynth/freq", freq);
        }
    }    
}

//==============================================================================
bool MIDIVelocityModifyAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* MIDIVelocityModifyAudioProcessor::createEditor()
{
    return new MIDIVelocityModifyAudioProcessorEditor (*this);
}

//==============================================================================
void MIDIVelocityModifyAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void MIDIVelocityModifyAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================

// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new MIDIVelocityModifyAudioProcessor();
}
