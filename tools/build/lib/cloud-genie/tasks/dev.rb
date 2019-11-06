namespace :dev do
  desc "Create Azure Pipelines from the repo YAML specs"
  task :pipelines do
    include Schott::DevResources
    create_pipelines($configuration.project_name, $configuration.project_repository, $configuration)
  end
  desc "Login using the service principal credentials"
  task :login do
    include Schott::AzureCLI
    azure_principal_login($configuration)
  end
end
