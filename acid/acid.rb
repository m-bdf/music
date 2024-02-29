use_debug false
use_bpm 150

kick = load_sample :bd_tek
hat = load_sample :hat_noiz

define :slide do |from, to|
  return (line from, to, steps: 5, inclusive: true).ramp
end

with_fx :ping_pong, amp: 0.5 do
  in_thread name: :acid do
    use_synth :tb303
    
    define :play_pick do |note|
      play note, release: 0.25
      sleep 0.5
    end
    
    define :play_slide do |from, to|
      p = play from
      sleep 0.5
      control p, note: to, amp: 0.75,
        cutoff: (slide 60,100).repeat(5).tick
      sleep 0.5
    end
    
    10.times do
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
end

with_fx :ping_pong, amp: 0.5 do
  in_thread name: :pad do
    use_synth :rhodey
    
    4.times do
      play [:A2,[:E2,:E3].tick], attack: 8
      sleep 8
    end
  end
end

with_fx :ping_pong do
  in_thread name: :bass, delay: 5*8 do
    use_synth :dsaw
    use_synth_defaults release: 0.5
    
    (5*8).times do
      note = [:A1,:A1,:C2,:B1,:A1,:C2,:B1,:A1].tick
      
      play note
      sleep 0.4
      play note, amp: 0.5
      sleep 0.3
      play note, amp: 0.5
      sleep 0.3
    end
  end
end

with_fx :normaliser do
  with_fx :reverb do |reverb|
    in_thread name: :kick, delay: 6*8-1 do
      (4*8+1).times do
        control reverb, room: 1
        sample kick
        sleep 0.5
        control reverb, room: 0
        sample kick, on: (spread 1,8).tick
        sleep 0.5
      end
    end
  end
end

with_fx :hpf, amp: 0.25 do
  with_fx :gverb do
    in_thread name: :hat, delay: 7*8 do
      (3*8).times do
        sleep 0.5
        sample hat
        sleep 0.5
      end
    end
  end
end
