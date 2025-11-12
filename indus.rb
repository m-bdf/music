use_debug false
use_bpm 180

eval_file "~/Documents/music/lib.rb"

goyave = load_sample "~/Documents/music/goyave.ogg"
kick = load_sample :bd_tek
hat = load_sample :hat_noiz


### DRUMS

define :kick do |v|
  with_fx :distortion, mix: 0.5 do
    with_fx :tanh, mix: 0.5 do
      with_fx :normaliser do |level|
        with_fx :reverb do
          8.times do
            sample kick if tick % 8 > 6 || v > 0
            sleep 0.5

            with_fx :lpf do
              sample hat if look % 8 > 3
            end if v > 1

            sample kick if look % 8 == 7
            sleep 0.5
          end

          control level, amp: 0, amp_slide: 1
        end
      end
    end
  end
end

define :hats do |v|
  with_fx :hpf, amp: 0.5 do
    with_fx :gverb do |gverb|
      32.times do
        sleep 0.15
        control gverb, mix: tick % 4 / 3
        sample hat if look % 4 > 0
        sleep 0.1
      end
    end
  end
end

define :scre do |v|
  with_fx :nhpf, amp: 0.5 do
    with_fx :krush do
      with_fx :slicer do |slicer|
        with_fx :reverb, room: 0.2 do
          control slicer, mix: 0
          sample hat
          sample goyave, start: 0.5, rate: -1, pitch: 24
          sleep 2
          control slicer, mix: 1
          sleep 6
        end
      end
    end
  end
end


### SONG

arrange [
  {
    kick: [0,1,1,2,2,2,2],
    hats: [_,_,_,0,0,0,0],
    scre: [0,0,0,0,0,0,0],
  },
]
