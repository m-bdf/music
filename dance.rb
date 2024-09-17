use_debug false
use_bpm 150
use_synth :tb303
use_transpose 2

eval_file "~/Documents/music/lib.rb"


### BASS

define :bass do |v|
  with_fx :compressor do
    with_fx :rhpf, cutoff: 40 do
      with_fx :ping_pong, mix: 0.1 do |pp|
        with_fx :slicer, wave: 0, mix: 0 do |slicer|
          if v == 2
            control slicer, mix: 1, mix_slide: 8
            control pp, mix: 1, mix_slide: 8
          elsif v == 1
            at rand_i 8 do
              control slicer, mix: 1, amp: 2
              sleep 1
              control slicer, mix: 0, amp: 1
            end
          end

          8.times do |n|
            note = v == 1 ? [:D2,:C2,:A1,:A1].tick : :A1
            sleep 0.5 if n % 4 > 0

            with_fx :band_eq, freq: 110, db: 40, amp: 0.5 do
              play note, wave: 2, cutoff: 80 + n * 5, release: 0.5
            end if v == 1

            sleep 0.5 if n % 4 == 0
            play note, wave: n / 4, cutoff: 80, release: 0.5
            sleep 0.5
          end
        end
      end
    end
  end
end


### DRUMS

define :play_click do
  play :A2, wave: 1, attack: 0, release: 0.01
end

define :kick do |v|
  with_fx :compressor do
    with_fx :rhpf, cutoff: 30 do
      with_fx :wobble, cutoff_max: 80 do
        with_fx :gverb, damp: 1 do
          8.times do
            play_click
            play :A1, wave: 2, cutoff: 20, release: 0.5
            sleep 1
          end
        end
      end
    end
  end
end

define :hats do |v|
  with_fx :slicer, amp: 2 do
    with_fx :gverb, damp: 1 do
      with_fx :distortion do
        8.times do
          with_fx :rhpf, amp: 0.15 do
            sleep 0.5
            play_click
            sleep 0.25
            play_click if tick % 16 == 15
            sleep 0.25
          end

          with_fx :rlpf, cutoff: 120 do
            play_click if look % 2 == 0
          end if v > 0
        end
      end
    end
  end
end


### LEAD

define :word do |v|
  with_fx :compressor, amp: 0.5 do |level|
    with_fx :nrlpf, cutoff: 110 do
      with_fx :slicer, mix: 0 do |slicer|
        with_fx :reverb, room: 0 do
          with_fx :vowel do |vowel|
            with_fx :tanh do
              play sustain: 8

              (spread 1 << v, 4).rotate(1).each do |me|
                control note: [:A2,:A1,:A2,:A2].tick

                if me
                  control vowel, vowel_sound: 3
                  control vowel, amp: 0, amp_slide: 1
                  control slicer, mix: 1, mix_slide: 1
                  sleep 2
                  control vowel, amp: 1, amp_slide: 0
                  control slicer, mix: 0, mix_slide: 0
                else
                  control note: :C3
                  control vowel, vowel_sound: 3
                  sleep 0.25
                  control note: :D3
                  control vowel, vowel_sound: 5
                  sleep 0.75
                  control note: :C3
                  control vowel, vowel_sound: 1
                  sleep 0.25
                  control note: :A2
                  sleep 0.75
                end
              end

              control level, amp: 0
            end
          end
        end
      end
    end
  end
end


### SONG

arrange [
  {
    bass: [_, 0,0,0,1, 1,1,1,_, 1,1,1,0, 1,1,1,2],
    kick: [_, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,_],
    hats: [_, _,_,0,0, 1,1,1,_, 1,1,1,1, 1,1,0,_],
    word: [1, _,_,_,_, _,_,_,0, 1,0,1,0, 1,0,1,0],
  },
  {
    bass: [1,1,1,0, 1,1,1,_, 1,1,1,0, 1,1,1,2],
    kick: [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,_],
    hats: [1,1,1,0, 1,1,1,_, 1,1,1,1, 1,1,0,_],
    word: [_,_,_,_, _,_,_,0, 1,0,1,0, 1,0,1,0],
  },
  {
    bass: [0,0,0,1, 0,0,0,2, 1,1,1,1, 1,1,1,2, 0,2],
    kick: [0,0,0,0, 0,0,0,_, 0,0,0,0, 0,0,0,0, _,_],
    hats: [1,1,1,1, 1,1,0,_, 1,1,1,0, 1,1,1,_, 0,_],
    word: [2,2,2,0, 2,2,2,0, _,_,_,_, _,_,_,_, _,_],
  },
]
