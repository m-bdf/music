use_debug false
use_bpm 150

eval_file "~/Documents/music/lib.rb"

kick = load_sample :bd_tek


### BASS

define :bass do |v|
  with_fx :ping_pong do
    use_synth :dsaw
    use_synth_defaults release: 0.5

    8.times do
      n = [
        [:A1,:G1,:G1,:G1,:F1,:E1,:E1,:E1],
        [:A1,:C2,:C2,:C2,:B1,:F1,:F1,:F1],
      ][v].tick

      play n
      sleep 0.7
      play n, amp: 0.7
      sleep 0.3
    end
  end
end


### DRUMS

define :kick do |v|
  define :play_kick do
    use_synth :gabberkick
    use_octave v
    play :A1, sustain: 0.25

    sample kick
    sleep 0.4
    sample kick, amp: 0.4
    sleep 0.3
    sample kick, amp: 0.7
    sleep 0.3
  end

  with_fx :distortion do
    if v == 0
      play_kick
      sleep 7
    else
      8.times do
        play_kick
      end
    end
  end
end


### LEAD

define :lead do |v|
  with_fx :hpf, cutoff: 60, amp: 0.5 do
    n = [
      [:A3,:G4,:G4,:G4,:G4,:E4,:F4,:E4,:E4,:E4,:E4,:C4],
      [:A3,:C4,:C4,:C4,:C4,:A3,:B3,:F4,:F4,:F4,:E4,:C4],
    ][v % 2]

    t = [1,0.4,0.3,0.3,1,1,1,0.4,0.3,0.3,1,1]

    use_synth_defaults ramp_ratio: 0

    synths :winwood_lead, :supersaw do
      play_pattern_timed n, t, sustain: 0.5
    end
  end
end


### SONG

arrange [
  {
    lead: [1,0,0,0,1,0,0,0,1,0,0,0,1],
    bass: [_,0,0,0,1,0,0,0,1,0,0,0,1],
    kick: [0,1,1,1,0,1,1,1,0,1,1,1,0],
  },
]
