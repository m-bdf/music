use_debug false
use_bpm 150

run_file "~/Documents/music/lib.rb"


### PATTERNS

define :acid do |v|
  define :play_slide do |*notes|
    play notes.first, release: notes.length / 2 + 1
    
    notes.each do |n|
      control note: n, cutoff: (line 60,100).tick
      sleep 0.5
    end
  end
  
  with_fx :ping_pong, amp: 0.5 do
    use_synth :tb303
    use_synth_defaults attack: 0.1,
      cutoff: 0, cutoff_slide: 0.1
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :E4,:D4,:C4,:B3
    play_slide :D4,:C4,:B3,:G3
    
    play_slide :A3,:A3
    play_slide :E3,:C4
    play_slide :B3,:B3
    play_slide :E3,:B3
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :C4,:B3
    play_slide :C4,:E4,:B3,:G3
    play_slide :G3,:A3
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :E4,:G4,:C4,:B3
    play_slide :D4,:B3,:A3,:G3
    
    play_slide :A3,:A3
    play_slide :E3,:C4
    play_slide :B3,:B3
    play_slide :E3,:B3
    
    play_slide :A3,:A3,:A3
    play_slide :E3
    play_slide :C4,:D4
    play_slide :C4,:B3,:A3,:G3
    play_slide :G3,:A3
  end
end


### SONG

arrange [
  {
    acid: [0,0,0,0],
  }
]
