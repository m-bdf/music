use_debug false
use_bpm 180

goyave = load_sample "~/Documents/music/goyave.ogg"
kick = load_sample :bd_tek
hat = load_sample :hat_noiz

with_fx :nhpf, amp: 0.5 do
  with_fx :krush do
    with_fx :slicer do |slicer|
      with_fx :reverb, room: 0.2 do
        in_thread name: :screech do
          7.times do
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
end

with_fx :distortion, mix: 0.5 do
  with_fx :tanh, mix: 0.5 do
    with_fx :normaliser do
      with_fx :reverb do |reverb|
        in_thread name: :kick, delay: 8-1 do
          (6*8+1).times do
            control reverb, room: 1
            sample kick
            sleep 0.5

            control reverb, room: 0
            sample kick, on: (spread 1,8).tick
            sleep 0.5
          end
        end
      end

      with_fx :lpf do
        in_thread name: :scratch, delay: 3*8 do
          (4*8).times do
            sleep 0.5
            sample hat, on: (knit 0,5,1,3).rotate.tick
            sleep 0.5
          end
        end
      end
    end
  end
end

with_fx :hpf, amp: 0.5 do
  with_fx :gverb do
    in_thread name: :hat, delay: 3*8 do
      (4*8).times do
        sleep 0.6
        sample hat
        sleep 0.4
      end
    end
  end

  in_thread name: :hat_roll, delay: 3*8 do
    (4*8*4).times do
      sleep 0.125
      sample hat, on: !(spread 1,4).tick
      sleep 0.125
    end
  end
end
