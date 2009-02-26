module MoveEnhancements
  def reverse_move(move)
    move.reverse.map do |partial_move|
      partial_move.map do |part|
        case part
          when :place
            :remove
          when :remove
            :place
          else
          part
        end
      end
    end
  end
end