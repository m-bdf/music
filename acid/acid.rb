use_debug false
use_bpm 150

kick = load_sample :bd_tek
hat = load_sample :hat_noiz


### PATTERNS


define :acid do |n|
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
      cutoff: (slide 60,100).repeat(5).tick
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

define :pad do |n|
  with_fx :ping_pong, amp: 0.5 do
    use_synth :rhodey
    
    play [:A2,[:E2,:E3].tick], attack: 8
    sleep 8
  end
end

define :bass do |n|
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

define :kick do |n|
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

define :hat do |n|
  with_fx :hpf, amp: 0.5 do
    8.times do
      sleep 0.5
      sample hat
      sleep 0.5
    end
  end
end


### SONG


song = {
  acid: [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  pad:  [1,1,1,1,0,0,0,0,0,0,0,0,0,0],
  bass: [0,0,0,0,0,1,1,1,1,1,1,1,1,1],
  kick: [0,0,0,0,0,0,0,1,1,1,1,0,1,1],
  hat:  [0,0,0,0,0,0,1,0,0,1,1,0,1,1],
}

song.each do |pattern, playlist|
  in_thread do
    playlist.each do |n|
      if n > 0
        send pattern, n
      else
        sleep 8
      end
    end
  end
end
