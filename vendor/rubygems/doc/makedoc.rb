Dir.glob("*.txt").each do |file|
  htmlfile = File.basename(file)[0...-(File.extname(file).size)]+".html"
  `wiki2html -b . -s doc.css -t "RubyGems" -o #{htmlfile} #{file}`
end