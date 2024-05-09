/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

//==============================================================================
/**
*/
class MIDIVelocityModifyAudioProcessor  : public juce::AudioProcessor
{
public:
    //==============================================================================
    MIDIVelocityModifyAudioProcessor();
    ~MIDIVelocityModifyAudioProcessor() override;

    //==============================================================================
    void prepareToPlay (double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;

   #ifndef JucePlugin_PreferredChannelConfigurations
    bool isBusesLayoutSupported (const BusesLayout& layouts) const override;
   #endif

    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    //==============================================================================
    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override;

    //==============================================================================
    const juce::String getName() const override;

    bool acceptsMidi() const override;
    bool producesMidi() const override;
    bool isMidiEffect() const override;
    double getTailLengthSeconds() const override;

    //==============================================================================
    int getNumPrograms() override;
    int getCurrentProgram() override;
    void setCurrentProgram (int index) override;
    const juce::String getProgramName (int index) override;
    void changeProgramName (int index, const juce::String& newName) override;

    //==============================================================================
    void getStateInformation (juce::MemoryBlock& destData) override;
    void setStateInformation (const void* data, int sizeInBytes) override;

    // 4) Add to AudioProcessor class a variable that will store the velocity of the Note On message:
    // now we need a function that set the value of this variable whenever the slide value is changed
    float noteOnVel;
    float freq;
    //********************************************************************************************//



private:
    //==============================================================================
    juce::OSCSender sender;

    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (MIDIVelocityModifyAudioProcessor)
};
