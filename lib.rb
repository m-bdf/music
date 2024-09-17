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

define :_ do nil end
