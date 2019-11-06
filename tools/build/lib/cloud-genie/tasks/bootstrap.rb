namespace :bootstrap do
  desc "Creates a service principal for use in automation"
  task :principal do
    include Schott::AzureCLI
    create_principal($configuration)
  end
  desc "Create a project backend.tf scaffold for resource authentication"
  task :backend do
    include Schott::Terraform
    backend_config = generate_backend_config($configuration)
    puts "Created #{backend_config}."
  end
end
