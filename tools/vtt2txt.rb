def parse_webvtt(input)
  cues = []
  cue = nil
  input.each do |line|
    if line =~ /^([\d:.]+) --> ([\d:.]+)(.*)$/
      cue = { start: parse_time($1), end: parse_time($2), text: [] }
    elsif line =~ /^\s*$/
      cues << cue unless cue.nil?
      cue = nil
    elsif cue
      cue[:text] << line.chomp
    end
  end
  cues
end

def parse_time(s)
  s.split(':').map(&:to_f).reverse.each_with_index.sum { |v, i| v * 60**i }.round(2)
end

input = $stdin.readlines
cues = parse_webvtt(input)
events = []
cues.each_with_index do |cue, i|
  events << { type: :start, t: cue[:start], text: cue[:text].join("\n"), id: i }
  events << { type: :end, t: cue[:end], id: i }
end
events.sort_by! { |e| e[:t] }

showing = nil
by_time = {}
events.each do |event|
  case event[:type]
  when :start
    showing = event[:id]
    by_time[event[:t]] = event[:text]
  when :end
    by_time[event[:t]] = nil if showing == event[:id] && !by_time.key?(event[:t])
  end
end

# ChatGPT prompt: Write me a Ruby function convert_straight_quotes_to_smart_quotes
def convert_straight_quotes_to_smart_quotes(text)
  text = text.dup
  # Single quotes
  text.gsub!(/(\A|[^'])'([^']|$)/, '\1’\2')
  text.gsub!(/'/, '’')

  # Double quotes
  text.gsub!(/(\A|[^"])\"([^\"]|$)/, '\1“\2')
  text.gsub!(/"/, '”')

  return text
end

by_time.sort.each do |t, text|
  puts "[@%.2f]" % [t]
  puts convert_straight_quotes_to_smart_quotes((text || '-').strip)
  puts
end
