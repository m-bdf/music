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
  {}.merge(*song) do |_, p1, p2|
    p1 + p2
  end.each do |pattern, playlist|
    in_thread do
      playlist.drop(skip).each do |v|
        if v
          send pattern, v
        else
          sleep 8
        end
      end
    end
  end
end

define :_ do
  return nil
end
