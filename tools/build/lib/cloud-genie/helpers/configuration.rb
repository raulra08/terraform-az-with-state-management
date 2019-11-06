module Gaudi::Configuration::SystemModules::SchottProject
  #:stopdoc:
  def self.list_keys
    []
  end
  def self.path_keys
    []
  end
  #:startdoc:
  #The name of the project
  #
  #The value of this parameter is used in creating path and filenames
  #so if it is changed, several paths will need to be renamed (e.g. the backend configuration file)
  def project_name
    @config["project_name"]
  end

  def project_repository
    @config["project_repository"]
  end

  #Location of the Azure foundation (bootstrap) configuration
  #
  #Path relative to the repository root
  def azure_foundation
    return @config.fetch("azure_foundation", "src/azure/foundation")
  end

  #Location of the Azure project (managed) configuration
  #
  #Path relative to the repository root
  def azure_project
    return @config.fetch("azure_project", "src/azure/project")
  end

  #The name to use for the service principal used in automation
  def azure_principal
    return @config.fetch("azure_principal", "#{project_name()}bot")
  end
end
