use_debug false
use_bpm 180
use_synth :tb303
use_transpose 2

eval_file "~/Documents/music/lib.rb"


### BASS

define :bass do |v|
  with_fx :compressor do
    with_fx :rhpf, cutoff: (v + 1) * 20 do
      with_fx :wobble, res: 0 do
        use_synth_defaults wave: 2, cutoff: 80, cutoff_slide: 1

        if v == 0
          sleep 0.5
          play :A0, attack: 4, release: 4
          sleep 4
          control note: :A1, cutoff: 110, cutoff_slide: 2
          sleep 1
          control note: :A0, note_slide: 3, amp: 0.5, wave: 0
          sleep 2.5
        else
          sleep 0.5
          play :A1, cutoff: 90, release: 3
          sleep 1
          control note: :A0, amp: 0.5, wave: 1, cutoff: 110
          sleep 2
          play :A0, amp: 0.5, sustain: 0.5, release: 0
          sleep 1
          play :A1, release: 4
          sleep 2
          control note: :A0, amp: 0.5, wave: 1, cutoff: 100
          sleep 1.5
        end
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
  play :A1, wave: 2, cutoff: 20, release: 0.5
end

define :play_res do
  play :A0, wave: 2, cutoff: 40, release: 0.1
end

define :kick do |v|
  with_fx :compressor do
    with_fx :rlpf, cutoff: 90 do
      with_fx :distortion, mix: v / 3.0 do
        with_fx :rhpf, cutoff: 30 do
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
                play_res if v == 0
                sleep 0.5
              end
            end
          end
        end
      end
    end
  end
end

define :roll do |v|
  with_fx :rhpf, amp: 0.25 do |rhpf|
    with_fx :slicer, wave: 3 do
      with_fx :reverb, room: v / 4.0 do
        with_fx :gverb, damp: 1 do
          8.times do
            at (line 0,1) do |t|
              control rhpf, res: t, mix: t
              play_click if t < v / 4.0
            end if tick % 4 < v

            sleep 0.5
            play_click
            sleep 0.5
          end
        end
      end
    end
  end
end


### LEAD

define :pads do |v|
  with_fx :reverb, amp: 0.25 do
    with_fx :slicer, phase: 0.5 do
      play [:A4,:C4,:E4], wave: 2, sustain: 7
      sleep 4
      control notes: [:C4,:E4] if v > 0
      sleep 2
      control notes: [:B3,:D4] if v > 1
      sleep 2
    end
  end
end

define :lead do |v|
  with_fx :ping_pong, amp: 0.25 do
    with_fx :tanh, krunch: v / 8.0 do
      tick_reset

      cutoff_min = look :cutoff
      cutoff_max = tick_set :cutoff, 60.0 + v * 10
      cutoff = range cutoff_min, cutoff_max.round(14)
      cutoff = [cutoff_max] if cutoff.length != 10

      define :play_pick do |note|
        play note, cutoff: cutoff.tick, release: 0.25
        sleep 0.5
      end

      define :play_slide do |from, to|
        play from, cutoff: cutoff.tick
        sleep v / 8.0
        control note: to
        sleep 1 - v / 8.0
      end

      if v == 0
        play :A3, cutoff: cutoff.tick, release: 4
        sleep 4
      else
        play_slide :A3,:E3
        play_slide :A3,:E4
        play_slide :C4,:D4
        play_pick :B3
        play_pick :G3
      end

      if v == 4
        play :A3, cutoff: cutoff.tick, release: 4
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
    bass: [_,0, _,0,_,1, _,2,1, _,1,2,3,2, 1,2,3,2, 1,2,_,_],
    kick: [_,_, 0,0,0,1, 0,2,1, 0,1,2,1,2, 0,1,2,3, 2,3,_,_],
    roll: [_,_, _,_,2,0, 1,0,1, 2,1,2,0,1, 2,1,0,_, 3,4,_,_],
    pads: [0,_, 0,_,0,_, 1,0,_, 2,1,2,0,_, 2,1,0,_, 1,0,2,0],
    lead: [_,_, _,_,_,_, _,_,_, _,_,_,_,_, _,_,_,_, _,_,_,_],
  },
  {
    bass: [3,0,2,1, 2,1,3,1, 2,1,3,1, 2,1,3,1, 2,1,3,1, _,0],
    kick: [_,_,_,_, 0,1,0,2, 0,1,2,_, 0,1,2,3, 2,3,2,1, _,_],
    roll: [_,_,2,0, 1,0,2,0, 1,2,1,0, 1,2,3,0, 3,2,1,0, _,4],
    pads: [_,_,_,_, _,_,0,_, 1,_,2,_, 1,0,2,0, 2,1,2,0, _,_],
    lead: [0,_,0,1, 2,3,2,4, 5,6,5,6, 3,2,1,0, 6,5,6,5, 4,_],
  },
  {
    bass: [1,3,1,2, 1,3,1,2, 1,3,2,1, 1,3,1,2, 1,3,2,1, 3,0],
    kick: [3,2,1,0, 2,1,2,1, 2,1,0,_, 2,1,2,1, 2,1,0,_, 3,_],
    roll: [3,2,1,0, 3,2,1,0, 2,0,1,0, 3,2,1,0, 2,0,1,0, 4,_],
    pads: [2,1,2,0, 2,1,0,_, 2,_,1,_, 2,1,0,_, 2,_,1,_, 0,_],
    lead: [6,5,6,4, 5,6,5,6, 3,2,1,0, 5,6,5,6, 3,2,1,0, _,0],
  },
]
