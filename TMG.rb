class TMG
  def initialize
    @lines = []
    @line = ""
    @source = []
    @possibleReads = ""
    @states = {}
  end
  attr_accessor :source, :line, :lines, :possibleReads, :states

  def initStates
    @lines.each do |line|
      @states[line.split(",")[0]] = Array.new @possibleReads.length
    end
  end

  def categorizeStates
    @lines.each do |line|
      transition = line.split(",")
      @states[transition[0]][@possibleReads.index(transition[1])] = transition
    end
  end

  def generateStates
    categorizeStates
    statesArray = []
    @states.each do |key, value|
      statesArray.push(key.to_i)
    end
    statesArray = statesArray.sort.map(&:to_s)

    statesArray.each do |key|
      puts key
      str = "\t//state " << key << 10 << "\t[" << 10
      @source.push(str)
      generateTransitions(key)
      str = "\t]," << 10
      @source.push(str)
    end
    @source.push("\t[" << 10 << "\t\t//halt state (because it is last in the file)" << 10 << "\t]" << 10)
  end

  def generateTransitions(state)

    for i in 0...@possibleReads.length
      @line = ""
      @line << "\t\t//read " << @possibleReads[i] << 10
      if @states[state][i] == nil
        @line << "\t\tnull"
      else

        @line << "\t\t{\"write\": \"#{@states[state][i][2]}\",\"direction\": \"#{@states[state][i][3]}\",\"next_state\": #{@states[state][i][4]}}"
      end
      if i != @possibleReads.length - 1
        @line << ","
      end
      @line << 10
      @source.push(@line)
    end
  end

  def clearFile
    File.open('GeneratedJSON.json', 'w') { |file| file.write("") }
  end

  def writeFile
    for line in @source
      File.open('GeneratedJSON.json', 'a') { |file| file.write(line) }
    end 
    puts "JSON gerado!"
  end

  def readModel
    file = File.open("inputPower.txt", 'r')
    @lines = file.readlines.map(&:chomp)
    @possibleReads = @lines.delete_at(0)
    file.close()
  end
end

tmg = TMG.new
tmg.line = ""
tmg.clearFile
tmg.line << "[" << 10
tmg.source.push(tmg.line)
tmg.readModel
tmg.initStates
tmg.generateStates

tmg.line = ""
tmg.line << "]" << 10
tmg.source.push(tmg.line)
tmg.writeFile