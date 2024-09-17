use_debug false
use_bpm 150

run_file "~/Documents/music/lib.rb"

kick = load_sample :bd_tek


### BASS

define :bass do |v|
  with_fx :ping_pong do
    use_synth_defaults release: 0.5
    
    synths :dsaw, :bass_foundation do
      8.times do
        play :A1
        sleep 0.5
        play :E1, amp: 0.4
        sleep 0.25
        play :E1, amp: 0.7
        sleep 0.25
      end
    end
  end
end


### DRUMS

define :kick do |v|
  with_fx :distortion do
    use_synth :gabberkick
    
    8.times do
      use_octave (line 0,3).tick
      play :A1, sustain: 0.3
      
      with_fx :reverb do
        sample kick
        sleep 0.5
        sample kick, amp: 0.4
        sleep 0.25
        sample kick, amp: 0.7
        sleep 0.25
      end
    end
  end
end


### SONG

arrange [
  {
    bass: [0,0,0,0],
    kick: [0,0,0,0],
  }
]
