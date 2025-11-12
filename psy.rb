use_debug false
use_bpm 120
use_transpose 2

eval_file "~/Documents/music/lib.rb"


### DRUMS

define :kick do |v|
  max = v == 0 ? :D5 : :D7

  with_fx :level, amp: 0.5 do
    with_fx :lpf, cutoff: max do |lpf|
      with_fx :rhpf, cutoff: :D3 do |hpf|
        8.times do
          synth :tb303, note: :D3, wave: 2, attack: 0, release: 0.7
          control note: :D1, note_slide: 0.1, res: 0, res_slide: 0.1

          control hpf, cutoff: :D1, cutoff_slide: 0.1
          control lpf, cutoff: :D3, cutoff_slide: 0.1
          sleep 0.3
          control hpf, cutoff: :D3, cutoff_slide: 0.3
          control lpf, cutoff: max, cutoff_slide: 0.3
          sleep 0.7
        end
      end
    end
  end
end

define :hats do |v|
  8.times do
    sleep 0.5
    sample :hat_yosh, amp: 0.1 if v % 2 == 0
    sample :hat_star, amp: 0.1 if v > 0
    sleep 0.5
  end
end


### BASS

define :melody do
  use_synth :fm
  use_synth_defaults attack: 0.01, note_slide: 0.2

  play :D3, sustain: 0.7
  sleep 0.7
  control note: :A2
  sleep 0.3
  control note: :D3
  sleep 0.5
  play :A3
  sleep 0.5

  pattern = [
    [:F3,:G3,:E3,:C3],
    [:D3,:A3,:F3,:G3],
    [:E3,:C3,:D3,:E3],
  ]

  pattern.each do |notes|
    play notes.tick
    sleep 0.3
    control note: notes.tick
    sleep 0.5
    play notes.tick
    sleep 0.5
    play notes.tick
    sleep 0.7
  end
end

define :bass do |v|
  accents = (line 0, 7, steps: 5, inclusive: true) + 0.3

  with_fx :distortion, distort: 0 do
    time_warp accents do |i|
      control distort: (v + i / 7) / 5, distort_slide: 0.5
      sleep 0.5
      control distort: 0
    end

    with_fx :rhpf do
      time_warp accents do
        4.times do
          sleep 0.1
          control amp: [0,1].tick, amp_slide: 0.02
        end
      end

      in_thread do # sidechain
        8.times do
          sleep 0.1
          control cutoff: :D2, cutoff_slide: 0.5
          sleep 0.5
          control res: 0.5, res_slide: 0.1
          sleep 0.3
          control cutoff: 100, cutoff_slide: 0.1, res: 0
          sleep 0.1
        end
      end

      melody
    end
  end
end


### VOICE

define :word do |v|
  with_fx :compressor, amp: 0.1 do |level|
    with_fx :nrlpf, cutoff: 110 do
      with_fx :slicer, mix: 0 do |slicer|
        with_fx :reverb, room: 0 do
          with_fx :vowel do |vowel|
            with_fx :tanh do
              synth :tb303, sustain: 8

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
    kick: [_, 1,1,0,0, 1,1,0,_, 0,0,1,1, 0,0,1,_],
    hats: [_, _,0,0,1, 0,0,1,1, 0,1,2,_, 2,1,0,_],
    bass: [_, _,_,0,0, 0,1,2,3, 2,3,2,3, 2,1,0,_],
    word: [1, _,_,_,_, _,_,_,_, _,_,_,_, _,_,_,0],
  },
]
