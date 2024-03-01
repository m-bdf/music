use_debug false
use_bpm 150

kick = load_sample :bd_tek
hat = load_sample :hat_noiz


### PATTERNS


define :acid do |v|
  define :slide do |from, to|
    return (line from, to, steps: 5, inclusive: true).ramp
  end
  
  define :play_pick do |note|
    play note, release: 0.25
    sleep 0.5
  end
  
  define :play_slide do |from, to|
    play from
    sleep 0.5
    
    control note: to, amp: 0.75,
      cutoff: (slide 60,100).repeat(6).tick
    sleep 0.5
  end
  
  with_fx :ping_pong, amp: 0.5 do
    use_synth :tb303
    use_synth_defaults amp: 0.5,
      slide: (slide 0.1,0).tick(:slide),
      attack: (slide 1,0).tick(:attack),
      cutoff: (slide 60,100).tick(:cutoff)
    
    play_slide :A3,:E3
    play_slide :A3,:E4
    play_slide :C4,:D4
    play_pick :B3
    play_pick :G3
    
    play_slide :A3,:E4
    play_slide :C4,:D4
    play_slide :B3,:G3
    play_pick :A3
    play_pick :B3
  end
end

define :pad do |v|
  with_fx :ping_pong, amp: 0.5 do
    use_synth :rhodey
    play [:A2,[:E2,:E3].tick], attack: 8
    sleep 8
  end
end

define :bass do |v|
  with_fx :ping_pong do
    use_synth :dsaw
    use_synth_defaults release: 0.5
    
    8.times do
      n = [:A1,:A1,:C2,:B1,:A1,:C2,:B1,:A1].tick
      
      play n
      sleep 0.75
      play n, amp: 0.5
      sleep 0.25
    end
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

define :hat do |v|
  with_fx :hpf, amp: 0.5 do
    8.times do
      sleep 0.5
      sample hat
      sleep 0.5
    end
  end
end


### SONG


_ = nil

song = {
  acid: [0,0,0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0],
  pad:  [0,0,0,0,0,_, _,_,_,_, _,_,_,_, _,_,_,_, _,_],
  bass: [_,_,_,_,_,_, 0,0,0,0, 0,0,0,0, 0,0,0,0, _,_],
  kick: [_,_,_,_,_,_, _,_,_,_, 0,0,0,_, 0,0,0,_, _,_],
  hat:  [_,_,_,_,_,_, _,_,0,0, _,_,0,_, 0,0,0,_, _,_],
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
