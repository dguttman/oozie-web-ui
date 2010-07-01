class FlowchartGenerator



  def self.create_node_hash_from_xml(xml)
    doc = REXML::Document.new(xml)
    
    nodes_data = {}
    
    doc.elements.each("//start") do |e|
      nodes_data["start"] = {}
      nodes_data["start"]["outputs"] = [e.attributes["to"]]
      nodes_data["start"]["type"] = "start"
    end
    
    doc.elements.each("//end") do |e|
      name = e.attributes["name"]
      nodes_data[name] = {}
      nodes_data[name]["type"] = "end"
      nodes_data[name]["outputs"] = []
    end
    
    doc.elements.each("//fork") do |e|
      name = e.attributes["name"]
      nodes_data[name] = {}
      nodes_data[name]["type"] ="fork"
      nodes_data[name]["outputs"] = []
      e.elements.each("//path") do |path|
        nodes_data[name]["outputs"] << path.attributes["start"]
      end
    end
    
    doc.elements.each("//join") do |e|
      name = e.attributes["name"]
      nodes_data[name] = {}
      nodes_data[name]["type"] ="join"
      nodes_data[name]["outputs"] = [e.attributes["to"]]
    end
    
    doc.elements.each("//kill") do |e|
      name = e.attributes["name"]
      nodes_data[name] = {}
      nodes_data[name]["type"] = "kill"
      nodes_data[name]["outputs"] = []
    end
    
    doc.elements.each("//action") do |e|
      name = e.attributes["name"]
      
      nodes_data[name] = {}
      nodes_data[name]["type"] = "action"
      nodes_data[name]["outputs"] = []

      e.elements.each("ok") do |ok|
        ok_to = ok.attributes["to"]
        nodes_data[name]["outputs"] << ok_to
      end
      
      e.elements.each("error") do |error|
        error_to = error.attributes["to"]
        nodes_data[name]["outputs"] << error_to
      end
      
    end
    
    doc.elements.each("//decision") do |e|
      name = e.attributes["name"]
      
      nodes_data[name] = {}
      nodes_data[name]["type"] = "decision"
      nodes_data[name]["outputs"] = []
      
      e.elements.each("switch/case") do |ok|
        ok_to = ok.attributes["to"]
        nodes_data[name]["outputs"] << ok_to
      end
      
      e.elements.each("switch/default") do |error|
        error_to = error.attributes["to"]
        nodes_data[name]["outputs"] << error_to
      end
      
    end
    
    # "start" #to
    # "end" #nothing
    #     
    # "fork" # sub:path-start
    # "join" # to
    # "kill" #nothing
    # "action" # sub:ok-to sub:error-to
    # 
    # "decision" #...

    
    return nodes_data
  end
  
  #flowchart methods

  def self.create_nodes(data)
    nodes ||= {}
    
    data.each do |name, attrs|
      nodes[name] ||= {}
      nodes[name]["name"] = name
      nodes[name]["outputs"] = attrs["outputs"]
      nodes[name]["type"] = attrs["type"]
      nodes[name]["inputs"] = []
      nodes[name]["x"] = 0.0
      nodes[name]["y"] = 0.0
      nodes[name]["size"] = 0.0
    end
    
    nodes.each do |from_node, attrs|
      attrs ||= {}
      attrs["outputs"] ||= []
      attrs["outputs"].each do |to_node|
        nodes[to_node] ||= {}
        nodes[to_node]["inputs"] ||= []
        nodes[to_node]["inputs"] << from_node
      end
    end
    
    root_nodes = nodes.select { |name,attrs| attrs["inputs"] == [] }.map {|n| n[0]}
    
    levels = [root_nodes]
    
    while levels.last.select {|name,attrs| nodes[name]["outputs"] != [] } != []
      outputs = []
      levels.last.each do |level_node, attrs|
        if nodes[level_node]["outputs"]
          outputs += nodes[level_node]["outputs"]
        else
          raise "Error creating flowchart. Please check your workflow.xml."
        end
      end
      outputs.uniq!
      levels << outputs
    end
    
    node_size = 1.0 / levels.length.to_f
    
    levels.each_with_index do |level_nodes, l|
      level_nodes.each_with_index do |name,i|
        nodes[name]["size"] = node_size
        x = l * nodes[name]["size"]
        y = i.to_f/level_nodes.size
        nodes[name]["x"] = x
        nodes[name]["y"] = y
      end
    end
    
    fail_nodes = []
    nodes.each do |name, attrs|
      if attrs["type"] == "kill"
        fail_nodes << name
      end
    end
    
    fail_nodes.each_with_index do |name, i|
      x = i.to_f/fail_nodes.size
      y = 1 - (node_size*1.5)
      nodes[name]["x"] = x
      nodes[name]["y"] = y
    end

    return nodes
  end
end