use_debug false
use_bpm 170
use_synth :tb303

eval_file "~/Documents/music/lib.rb"


### BASS

define :bass do |v|
  with_fx :wobble, res: 0 do
    with_fx :octaver, amp: 0.5 do
      if v == 0
        sleep 3
        play :A0, wave: 1, cutoff: 80, attack: 2, release: 3
        sleep 2
        control note: :A1, cutoff: 100, cutoff_slide: 3
        sleep 3
      else
        play :A1, wave: 1, cutoff: 90, attack: 0, release: 3
        sleep 1
        control note: :A0, cutoff: 120, cutoff_slide: 1
        sleep 2

        play :A0, cutoff: 80, sustain: 0.5, release: 0
        sleep 1

        play :A1, wave: 1, cutoff: 80, attack: 0, release: 4
        sleep 2
        control note: :A0, cutoff: 100, cutoff_slide: 1
        sleep 2
      end
    end
  end
end


### DRUMS

define :play_click do |**opts|
  play :A2, wave: 1, attack: 0, release: 0.01, **opts
end

define :kick do |v|
  define :play_kick do
    play_click
    play :A1, wave: 2, cutoff: 30, release: 0.5
  end

  with_fx :distortion, mix: v / 3.0 do
    with_fx :wobble, cutoff_max: 100 do
      with_fx :gverb, damp: 1 do
        8.times do
          play_kick
          sleep 0.5
          play_kick if tick % 8 > 7 - v
          sleep 0.25
          play_click if look % 8 > 8 - v
          sleep 0.25
        end
      end
    end
  end
end

define :roll do |v|
  with_fx :hpf, amp: 0.75 do
    with_fx :slicer, wave: 2 do
      with_fx :reverb, room: v / 4.0 do
        with_fx :gverb, damp: 1 do
          8.times do
            play_click if tick % 4 < v
            sleep 0.5
            play_click amp: 0.25
            sleep 0.25
            play_click amp: 0.5 if look % 2 == 0
            sleep 0.25
          end
        end
      end
    end
  end
end


### LEAD

define :lead do |v|
  with_fx :ping_pong, amp: 0.5 do
    cutoff = 60 + v * 10
    tick_reset(:cutoff)

    define :play_pick do |note|
      play note, cutoff: cutoff + tick(:cutoff), release: 0.25
      sleep 0.5
    end

    define :play_slide do |from, to|
      play from, amp: 0.5, cutoff: cutoff + tick(:cutoff)
      sleep 0.5
      control note: to, amp: 1, cutoff: (slide 60,100).tick
      sleep 0.5
    end

    play_slide :A3,:E3
    play_slide :A3,:E4
    play_slide :C4,:D4
    play_pick :B3
    play_pick :G3

    if v % 4 == 0
      play :A3, amp: 0.5, cutoff: cutoff + 5, release: 4
      control amp: 1, cutoff: cutoff + 30, cutoff_slide: 2
      sleep 4
    else
      play_slide :A3,:E4
      play_slide :C4,:D4
      play_slide :B3,:G3
      play_pick :A3
      play_pick :B3
      print look
    end
  end
end


### SONG

arrange [
  {
    bass: [0, 1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,0,_, _,1,0,1, 1,1,1,0, 1,1,1,0],
    kick: [_, _,_,0,0, 0,1,0,2, 0,1,2,1, 2,3,_,_, 0,1,0,2, 3,_,_,3, 2,0,2,1],
    roll: [_, _,_,_,_, 1,0,2,0, 1,2,3,4, 0,_,_,1, 2,3,4,3, 4,_,3,4, 3,2,3,4],
    lead: [_, _,_,_,_, _,_,_,_, _,_,_,_, _,_,0,1, 2,3,4,5, 6,6,5,4, 3,2,1,0],
  },
  {
    bass: [1,1,0,_, _,1,0,1, 1,1,1,1, 0,1,1,0, 1,1,1,1, 1,1,1,0, 1,1,0],
    kick: [2,3,_,_, 0,1,0,2, 3,_,_,3, 1,2,0,1, 2,3,_,_, 2,3,2,1, 2,3,_],
    roll: [0,_,_,1, 2,3,4,3, 4,_,3,4, 2,3,1,2, 0,1,_,0, 1,2,3,4, 0,_,_],
    lead: [_,_,0,1, 2,3,4,5, 6,6,5,6, 4,5,3,4, 2,3,1,2, 3,2,1,0, _,_,0],
  },
]
