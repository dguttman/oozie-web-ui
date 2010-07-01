class Workflow < ActiveRecord::Base
  
  versioned
  
  has_many :workflow_jobs
  
  VALID_CONTENT_TYPES = ["application/x-tar", "application/x-gzip"]   # "application/x-compressed"
  
  STATUS_CODES = {  0 => "NEW",
                    1 => "EXTRACTED",
                    2 => "PROCESSED: WORKFLOW XML",
                    3 => "PROCESSED: PROPERTIES XML",
                    4 => "READY",
                    -1 => "ERROR: Could not Extract Archive",
                    -2 => "ERROR: Could not Process Workflow XML",
                    -4 => "ERROR: Could not Copy Workflow to HDFS" }

  STATUS_TO_CODE = STATUS_CODES.invert
  
  has_attached_file :archive
  belongs_to :user
  
  validates_presence_of :name
  # validates_uniqueness_of :name, :scope => :user_id
  
  validates_attachment_presence :archive, :message => "Please provide a workflow archive."
  validates_attachment_content_type :archive, :message => "Invalid archive format. Accepted formats: .tar, .tar.gz, .tgz", :content_type => VALID_CONTENT_TYPES
  
  after_save :extract, :set_workflow_xml, :set_properties_xml, :send_to_hdfs
  
  def original_dir
    File.dirname(self.archive.path)
  end
  
  def extract_dir
    File.expand_path(File.join(original_dir, "..", "extracted"))
  end
  
  def escaped_name
    escaped_name = self.name.gsub(/\s|\/|\\|:|\?|\"|%|\||\*|<|>/, "_")
  end
  
  def hdfs_dir
    "#{DEFAULT_HDFS_DIR}/#{self.user.username}/#{self.id}-#{self.escaped_name}"
  end
  
  def workflow_xml_file
    workflow_xml_file = nil
    
    root_dir_xml = File.join(extract_dir, "workflow.xml")
    
    if File.exists?(root_dir_xml)
      workflow_xml_file = root_dir_xml
    else
      archive_dirs = Dir.entries(extract_dir) - [".", ".."].select {|e| File.directory? e}
      archive_dirs.each do |dir|
        sub_dir_xml = File.join(extract_dir, dir, "workflow.xml")
        workflow_xml_file = sub_dir_xml if File.exists?(sub_dir_xml)
      end
    end
    
    return workflow_xml_file
  end
  
  def workflow_xml_dir
    File.dirname(workflow_xml_file) if workflow_xml_file
  end
  
  def extract
    if self.status_code == 0
      FileUtils.mkdir_p(self.extract_dir)

      extracted = system("tar xvf #{self.archive.path} --directory #{extract_dir}/")

      if extracted
        set_status(1)
      else
        set_status(-1)
      end
      
    end
  end
  
  def set_workflow_xml
    if self.status_code == 1
      if workflow_xml_file
        self.workflow_xml = File.open(workflow_xml_file, "r").read
        set_status(2)
      else
        set_status(-2)
      end
    end
  end
  
  def set_properties_xml
    if self.status_code == 2
      if workflow_xml_dir
        config_default_xml_file = File.join(workflow_xml_dir, "config-default.xml")
        if File.exists? config_default_xml_file
          self.properties_xml = File.open(config_default_xml_file, "r").read
        end
      end
      set_status(3)
    end
  end
  
  def remote_list
    remote_list = IO.popen("$HADOOP_HOME/bin/hadoop fs -ls #{self.hdfs_dir}").readlines
  end
  
  def send_to_hdfs
    if self.status_code == 3

      put_success = hadoop_put(self.workflow_xml_dir)
      
      puts remote_list.join("\n")
      
      if put_success
        set_status(4)
      else
        set_status(-4)
      end
    end
  end

  def hadoop_put(source, dest=nil)
    full_dest = File.join(self.hdfs_dir, "#{dest}")
    cmd = "$HADOOP_HOME/bin/hadoop fs -put #{source} #{full_dest}"
    p cmd
    
    put_success = system("#{cmd}")
  end
  
  def hadoop_rm(source)
    cmd = "$HADOOP_HOME/bin/hadoop fs -rm #{source}"
    p cmd
    
    put_success = system("#{cmd}")
  end
  
  def remove_remote_workflow_xml
    hadoop_rm(File.join(self.hdfs_dir, "workflow.xml"))
  end

  def set_status(code)
    if self.status_code != code
      self.status_code = code
      self.save
    end
  end
  
  def status
    STATUS_CODES[self.status_code]
  end
  
  def properties_hash
    prop_hash = OozieApi.conf_xml_to_properties_hash(self.properties_xml)
    prop_hash.merge!({"oozie.wf.application.path" => hdfs_dir, "user.name" => self.user.username})
    prop_hash.merge!("group.name" => self.user.username) unless prop_hash["group.name"]
    return prop_hash
  end
  
  def jobs
    self.workflow_jobs.map{|j| j.job}.reverse
  end
  
end
