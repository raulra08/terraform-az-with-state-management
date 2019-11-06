namespace :check do
  desc "Raises an error if the foundation resources exist"
  task :foundation do
    include Schott::AzureCLI
    group_name = "rg-foundation"
    if resource_group_exists?(group_name, $configuration)
      raise GaudiError, "Foundation resources already present"
    else
      put "No foundation resources detected"
    end
  end
end
