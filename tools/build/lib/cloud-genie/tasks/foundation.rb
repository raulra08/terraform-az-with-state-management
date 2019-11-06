namespace :foundation do
  desc "Run terraform plan for the foundation resources"
  task :plan do
    include Schott::Terraform
    terraform_config = File.join($configuration.base, $configuration.azure_foundation)
    output_state = File.expand_path("out/foundation/gen/#{$configuration.project_name}.plan")
    input_state = File.expand_path("out/foundation/#{$configuration.project_name}.tfstate")
    mkdir_p(File.dirname(output_state))

    run_terraform("plan", "-state=#{input_state} -out=#{output_state}", terraform_config)
  end
  desc "Calculate and apply the current terraform configuration"
  task :apply do
    include Schott::Terraform
    terraform_config = File.join($configuration.base, $configuration.azure_foundation)
    output_state = File.expand_path("out/foundation/gen/#{$configuration.project_name}.tfstate")
    input_state = File.expand_path("out/foundation/#{$configuration.project_name}.tfstate")
    mkdir_p(File.dirname(output_state))

    run_terraform("apply", "-state=#{input_state} -state-out=#{output_state} -auto-approve", terraform_config)
    backend_config = generate_backend_config($configuration)
    puts "Created #{backend_config}. This should be uploaded to the secure files library."
  end
  desc "Copies the output state over the input state. To be used after succesfully importing"
  task :cycle do
    output_state = File.expand_path("out/foundation/gen/#{$configuration.project_name}.tfstate")
    input_state = File.expand_path("out/foundation/#{$configuration.project_name}.tfstate")
    cp(output_state, input_state)
  end
  desc "Show the current terraform state"
  task :show do
    terraform_config = File.join($configuration.base, $configuration.azure_foundation)
    input_state = File.expand_path("out/foundation/#{$configuration.project_name}.tfstate")
    Dir.chdir(terraform_config) do
      sh("terraform show #{input_state}")
    end
  end
end
