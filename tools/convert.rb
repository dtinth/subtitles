file = ARGV[0]

raise "File name should end with .src.mp4" unless file.end_with?(".src.mp4")
output = file.sub(/\.src\.mp4$/, ".mp4")
cmd = ["ffmpeg", "-i", file, "-c:v", "libx264", "-preset", "ultrafast", "-crf", "24", "-c:a", "libmp3lame", "-b:a", "128k", "-y", output]
p cmd
system(*cmd)