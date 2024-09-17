use_debug false
use_bpm 180
use_synth :tb303

eval_file "~/Documents/music/lib.rb"


### BASS

define :bass do |v|
  with_fx :hpf, cutoff: v * 30 do
    with_fx :wobble, res: 0 do
      use_synth_defaults wave: 2, cutoff: 80, cutoff_slide: 1

      if v == 0
        play :A0, attack: 4, release: 4
        sleep 4
        control note: :A1, cutoff: 110, cutoff_slide: 2
        sleep 1
        control note: :A0, note_slide: 3, amp: 0.5, wave: 0
        sleep 3
      else
        play :A1, cutoff: 90, release: 3
        sleep 1
        control note: :A0, amp: 0.5, wave: 1, cutoff: 110
        sleep 2
        play :A0, amp: 0.5, sustain: 0.5, release: 0
        sleep 1
        play :A1, release: 4
        sleep 2
        control note: :A0, amp: 0.5, wave: 1, cutoff: 100
        sleep 2
      end
    end
  end
end


### DRUMS

define :play_click do
  play :A2, wave: 1, attack: 0, release: 0.01
end

define :play_kick do
  play_click
  play :A1, wave: 2, cutoff: 30, release: 0.5
end

define :play_res do
  play :A0, wave: 2, cutoff: 30, release: 0.1
end

define :kick do |v|
  with_fx :distortion, mix: v / 3.0 do
    with_fx :wobble, cutoff_max: 100 do
      with_fx :gverb, damp: 1 do
        8.times do
          play_kick
          sleep 0.5

          if tick % 8 > 7 - v
            play_kick
            sleep 0.25
            play_click
            sleep 0.25
          else
            play_res
            sleep 0.5
          end
        end
      end
    end
  end
end

define :roll do |v|
  with_fx :hpf, amp: 0.5 do
    with_fx :slicer, wave: 3 do
      with_fx :reverb, room: v / 4.0 do
        with_fx :gverb, damp: 1 do
          8.times do
            play_click if tick % 4 < v
            sleep 0.5
            play_click
            play_click
            sleep 0.25
            play_click if look % 2 == 0
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
    with_fx :tanh, krunch: v / 12.0 do
      tick_set 60 + v * 10

      define :play_pick do |note|
        play note, cutoff: tick, release: 0.25
        sleep 0.5
      end

      define :play_slide do |from, to|
        play from, cutoff: tick
        sleep v / 12.0
        control note: to
        sleep 1 - v / 12.0
      end

      if v == 0
        play :A3, cutoff: tick, release: 4
        sleep 4
      else
        play_slide :A3,:E3
        play_slide :A3,:E4
        play_slide :C4,:D4
        play_pick :B3
        play_pick :G3
      end

      if v == 4
        play :A3, cutoff: tick, release: 4
        sleep 4
      else
        play_slide :A3,:E4
        play_slide :C4,:D4
        play_slide :B3,:G3
        play_pick :A3
        play_pick :B3
      end
    end
  end
end


### SONG

arrange [
  {
    bass: [0,1,1,1, 2,1,2,1, 2,1, 2,1,2,1],
    kick: [_,_,_,_, 0,0,0,1, 0,2, 0,1,2,3],
    roll: [_,_,4,2, _,_,1,0, 2,0, 1,2,3,4],
    lead: [_,_,_,_, _,_,_,_, _,_, _,_,_,_],
  },
  {
    bass: [3,0,2,1, 2,1,2,1, 2,1,2,1, 3,3],
    kick: [_,_,_,_, 0,1,0,2, 0,1,2,3, _,_],
    roll: [_,_,_,0, 1,0,2,0, 1,2,3,0, 2,4],
    lead: [0,_,0,1, 2,3,2,4, 5,6,5,6, _,_],
  },
  {
    bass: [1,2,1,2, 1,2,1,2, 1,2,1,2, 3,0],
    kick: [3,2,1,0, 2,1,2,1, 2,1,0,_, 3,_],
    roll: [4,3,2,1, 0,4,3,2, 1,0,4,_, 4,_],
    lead: [6,5,6,4, 6,5,6,4, 3,2,1,0, _,0],
  },
]
