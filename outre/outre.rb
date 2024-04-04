use_debug false
use_bpm 150

kick = load_sample :bd_tek
hat = load_sample :hat_noiz


### PATTERNS


define :acidd do |v|
  with_fx :ping_pong, amp: 0.5 do
    use_synth :tb303
    use_synth_defaults attack: 0.1
    
    [:A3,:A3,:A3,:E3,:E4,:D4,:C4,:B3,:D4,:C4,:B3,:G3,
     :A3,:A3,:E3,:C4,:B3,:B3,:E3,:B3,
     :A3,:A3,:A3,:E3,:C4,:B3,:C4,:E4,:B3,:G3,:G3,:A3,
     :A3,:A3,:A3,:E3,:E4,:G4,:C4,:B3,:D4,:B3,:A3,:G3,
     :A3,:A3,:E3,:C4,:B3,:B3,:E3,:B3,
     :A3,:A3,:A3,:E3,:C4,:D4,:C4,:B3,:A3,:G3,:G3,:A3,
    ].each do |n|
      play n, cutoff: (line 60,100).tick
      sleep 0.5
    end
  end
end


define :acid do |v|
  define :play_slide do |*notes|
    play notes[0], release: notes.length / 2 + 1
    
    notes.each do |n|
      control note: n, cutoff: (line 60,100).tick
      sleep 0.5
    end
  end
  
  with_fx :ping_pong, amp: 0.5 do
    use_synth :tb303
    use_synth_defaults attack: 0.1,
      cutoff: 0, cutoff_slide: 0.1
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :E4,:D4,:C4,:B3
    play_slide :D4,:C4,:B3,:G3
    
    play_slide :A3,:A3
    play_slide :E3,:C4
    play_slide :B3,:B3
    play_slide :E3,:B3
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :C4,:B3
    play_slide :C4,:E4,:B3,:G3
    play_slide :G3,:A3
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :E4,:G4,:C4,:B3
    play_slide :D4,:B3,:A3,:G3
    
    play_slide :A3,:A3
    play_slide :E3,:C4
    play_slide :B3,:B3
    play_slide :E3,:B3
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :C4,:D4
    play_slide :C4,:B3,:A3,:G3
    play_slide :G3,:A3
  end
end


define :kick do |v|
  with_fx :normaliser do
    with_fx :reverb do |reverb|
      8.times do
        control reverb, room: 1
        sample kick
        sleep 0.5
        
        control reverb, room: 0
        sample kick,
          on: (spread 1,8).reverse.tick
        sleep 0.5
      end
    end
  end
end


### SONG


_ = nil

song = {
  acid: [0,0,0,0],
  ##| kick: [0,0,0,0],
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
