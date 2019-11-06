namespace :project do
  desc "Run terraform plan for the project resources"
  task :plan do
    include Schott::Terraform
    validate_tf_project($configuration.project_name, $configuration)
    terraform_config = File.join($configuration.base, $configuration.azure_project)
    output_state = File.expand_path("out/project/gen/#{$configuration.project_name}.plan")
    mkdir_p(File.dirname(output_state))

    run_terraform("plan", " -out=#{output_state}", terraform_config)
  end
  desc "Apply the terraform configuration for the project resources"
  task :apply do
    include Schott::Terraform
    validate_tf_project($configuration.project_name, $configuration)
    terraform_config = File.join($configuration.base, $configuration.azure_project)
    terraform_cmd = "terraform apply"

    run_terraform("apply", "-auto-approve", terraform_config)
  end
  task :show do
    include Schott::Terraform
    validate_tf_project($configuration.project_name, $configuration)
    terraform_config = File.join($configuration.base, $configuration.azure_project)
    input_state = File.expand_path("#{terraform_config}/.terraform/terraform.tfstate")
    Dir.chdir(terraform_config) do
      sh("terraform show")
    end
  end
  task :import do
    include Schott::Terraform
    validate_tf_project($configuration.project_name, $configuration)

    terraform_config = File.join($configuration.base, $configuration.azure_project)
    tf_address = ENV.fetch("TF_ADDRESS", "")
    res_id = ENV.fetch("TF_ID", "")

    raise "Missing parrameters (TF_ADDRESS or TF_ID empty)" if tf_address.empty? || res_id.empty?

    run_terraform("import", "#{tf_address} #{res_id}", terraform_config)
  end
end
