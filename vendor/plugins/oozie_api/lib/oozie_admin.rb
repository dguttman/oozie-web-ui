module OozieAdmin
  
  def status
    resource = "/admin/status"
    oozie_get(resource)
  end

  def os_env
    resource = "/admin/os-env"
    oozie_get(resource)
  end

  def java_sys_properties
    resource = "/admin/java-sys-properties"
    oozie_get(resource)
  end

  def configuration
    resource = "/admin/configuration"
    oozie_get(resource)
  end

  def instrumentation
    resource = "/admin/instrumentation"
    oozie_get(resource)
  end
end

# /oozie/v0/admin/status
# /oozie/v0/admin/os-env
# /oozie/v0/admin/java-sys-properties
# /oozie/v0/admin/configuration
# /oozie/v0/admin/instrumentation