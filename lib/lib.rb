define :slide do |from, to|
  return line from, to, steps: 5, inclusive: true
end

define :synths do |lead, *synths, &fn|
  synths.each do |s|
    in_thread do
      use_synth s
      fn.call
    end
  end
  
  use_synth lead
  fn.call
end

define :arrange do |song, skip: 0|
  song.each do |part|
    part.each do |pattern, vs|
      in_thread do
        vs.drop(skip).each do |v|
          if v
            send pattern, v
          else
            sleep 8
          end
        end
      end
    end
    
    max = part.values.map(&:length).max
    sleep (max - skip) * 8
    skip = 0
  end
end

define :_ do
  return nil
end
