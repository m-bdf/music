use_bpm 120


### Samples


goyave = "goyave.ogg"
load_sample goyave


define :randomisa do |s = 0.2|
  with_fx :reverb do
    sample goyave, start: 0.12, sustain: s
  end
end

define :hmmmmmmmm do |s = 0.5|
  with_fx :echo, phase: 1, decay: 4, mix: 0.5 do
    sample goyave, start: 0.55, sustain: s, amp: 3
  end
end


### Synth


define :oscillate do |play, synth, opts|
  in_thread do
    with_synth synth do
      with_synth_defaults **opts do
        (method play).call
      end
    end
  end
end


define :bassline do
  play_pattern_timed [:As1] * 6, [0.5,0.25,0.25], slide: 1
  control note: :A1
  sleep 0.25
  play_pattern_timed [:A1] * 6, [0.25, 0.25, 0.25, 0.5]
end

define :bassfast do
  play_pattern_timed [:As1] * 5, [0.5, 0.25]
  play_pattern_timed [:A1] * 3, [0.25, 0.5]
end


define :bass do |play|
  synths = {
    saw: { attack: 0.04, decay: 0.5, sustain: 0, release: 0.28, amp: 0.5 },
    sine: { attack: 0.04, decay: 0.5, sustain: 0, release: 0.28 },
  }
  
  with_fx :lpf, cutoff: :E4 do
    synths.each do |synth, opts|
      in_thread do
        oscillate play, synth, opts
      end
    end
  end
end


### Parts


define :opening do tick_reset
  with_fx :echo, phase: 1, decay: 8 do
    sample goyave, rate: -1
    sleep 2
    sample :glitch_bass_g
  end
  
  in_thread do
    2.times do
      hmmmmmmmm
      sleep 8
    end
  end
  
  with_fx :lpf, slide: 4 do |lpf|
    4.times do
      c = (line :A1,:A10, steps: 3).tick
      control lpf, cutoff: c
      bass :bassline
      sleep 4
    end
  end
end


define :bass_loop do |n| tick_reset
  n.times do tick
    sample :bd_tek
    bass :bassline if (spread 1,4).look
    hmmmmmmmm      if (spread 1,8).look
    sleep 1
  end
end


define :rando_loop do |n| tick_reset
  (n-2).times do tick
    sample :bd_tek if (spread 1,2).look
    bass :bassline if (spread 1,8).look
    
    n = [2,0,0,1,0,1,2,0].look
    randomisa     if n == 2
    randomisa 0.1 if n == 1
    
    sleep 0.5
  end
  
  randomisa 0.5
  sleep 1
end


define :hmmmm_loop do |n| tick_reset
  n.times do tick
    sample :bd_tek if (spread 1,2).look
    bass :bassline if (spread 1,8).look
    
    n = [2,0,0,1,0,1,2,0].look
    hmmmmmmmm     if n == 2
    hmmmmmmmm 0.1 if n == 1
    
    sleep 0.5
  end
end

define :samba_loop do |n| tick_reset
  n.times do tick
    sample :bd_tek if (spread 5,16).look
    bass :bassline if (spread 1,16).look
    
    sleep 0.25
  end
end

define :samba_hat_loop do |bars|
  n.times do tick
    sample :bd_tek if (spread 5,16).look
    synth :noise, amp: 0.25, release: 0.1 if (spread 1,3).rotate(1).look
    bass :bassline if (spread 1,16).look
    
    ##| n = [2,0,0,1,0,1,2,0].look
    ##| hmmmmmmmm     if n == 2
    ##| hmmmmmmmm 0.1 if n == 1
    
    sleep 0.25
  end
end

define :fast_loop do |n| tick_reset
  n.times do tick
    sample :bd_tek if (spread 1,3).look
    synth :noise, amp: 0.25, release: 0.1 if (spread 1,3).rotate(1).look
    bass :bassfast if (spread 1,12).look
    
    #n = [2,0,0,1,0,1,2,0].look
    #hmmmmmmmm     if n == 2
    #hmmmmmmmm 0.1 if n == 1
    
    sleep 0.25
  end
end


define :bridge do tick_reset
  
end


define :outro do tick_reset
  
end


define :closing do tick_reset
  
end


### Composition


in_thread do bass_loop 4 end

#opening
#intro
#verse
#drop
#accel
#fast

#bridge
#verse
#drop
#outro
#closing
