use_debug false
use_bpm 150
use_synth :tb303
use_transpose 2

eval_file "~/Documents/music/lib.rb"


### BASS

define :bass do |v|
  with_fx :compressor do
    with_fx :rhpf, cutoff: v * 30 do
      with_fx :ping_pong, mix: 0.1 do |pp|
        with_fx :slicer, wave: 0, mix: 0 do |slicer|
          if v == 2
            control slicer, mix: 1, mix_slide: 8
            control pp, mix: 1, mix_slide: 8
          elsif v == 1
            at rand_i 7 do
              control slicer, mix: 1, amp: 2
              sleep 1
              control slicer, mix: 0, amp: 1
            end
          end

          8.times do |n|
            sleep 0.5
            play :A1, wave: n / 4, cutoff: 80, release: 0.5
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
      with_fx :wobble, cutoff_max: 100 do
        with_fx :gverb, damp: 1 do
          8.times do
            play_click
            play :A1, wave: 2, cutoff: 30, release: 0.5
            sleep 0.5
            play :A0, wave: 2, cutoff: 30, release: 0.1
            sleep 0.5
          end
        end
      end
    end
  end
end

define :hats do |v|
  with_fx :slicer do
    with_fx :gverb, damp: 1 do
      8.times do
        with_fx :rlpf do
          play_click if v > 0
        end if tick % 2 == 1

        sleep 0.5

        with_fx :rhpf, amp: 0.5 do
          play_click
          sleep 0.25
          play_click if look % 16 == 15
          sleep 0.25
        end
      end
    end
  end
end


### SONG

arrange [
  {
    bass: [0,0,0,0, 1,1,1,1, 1,1,1,1, 1,1,1,2],
    kick: [_,_,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0],
    hats: [_,_,_,_, 0,0,0,0, 1,1,1,1, 1,1,0,0],
  },
]
