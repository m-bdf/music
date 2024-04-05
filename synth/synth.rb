use_debug false
use_bpm 150

kick = load_sample :bd_tek


### PATTERNS


define :play_lead do |&fn|
  [:winwood_lead, :supersaw].each do |s|
    in_thread do
      use_synth s
      fn.call
    end
  end
end

define :lead do |v|
  with_fx :slicer, mix: v > 1, amp: 0.5 do
    n = [
      [:A3,:G4,:G4,:G4,:G4,:E4,:F4,:E4,:E4,:E4,:E4,:C4],
      [:A3,:C4,:C4,:C4,:C4,:A3,:B3,:F4,:F4,:F4,:E4,:C4],
    ][v % 2]
    
    t = [1,0.4,0.3,0.3,1,1,1,0.4,0.3,0.3,1,1]
    
    play_lead do
      play_pattern_timed n, t, sustain: 0.5
    end
    
    sleep 8
  end
end

define :bass do |v|
  with_fx :ping_pong do
    use_synth :dsaw
    use_synth_defaults release: 0.5
    
    8.times do
      n = [
        [:A1,:G1,:G1,:E1,:F1,:E1,:E1,:C1],
        [:A1,:C1,:C1,:A1,:B1,:F1,:F1,:C1],
      ][v].tick
      
      play n
      sleep 0.75
      play n, amp: 0.5
      sleep 0.25
    end
  end
end

define :kick do |v|
  define :play_kick do
    use_synth :gabberkick
    use_octave v
    play :A1, sustain: 0.25
    
    sample kick
    sleep 0.4
    sample kick, amp: 0.5
    sleep 0.3
    sample kick, amp: 0.5
    sleep 0.3
  end
  
  with_fx :distortion do
    if v == 0
      play_kick
      sleep 7
    elsif v == 1
      8.times do
        play_kick
      end
    end
  end
end


### SONG


play_lead do
  play :E4, slide: 0.5, sustain: 4
  (line :D4,:G3).each do |n|
    control note: n
    sleep 0.5
  end
end

sleep 4


_ = nil

song = {
  lead: [1,0,0,0,1,0,0,2,3,0,0,0,1],
  bass: [_,0,0,0,1,0,0,0,1,0,0,0,1],
  kick: [0,1,1,1,0,1,1,1,0,1,1,1,0],
}

song.each do |pattern, playlist|
  in_thread do
    playlist.each do |v|
      if v
        send pattern, v
      else
        sleep 8
      end
    end
  end
end
