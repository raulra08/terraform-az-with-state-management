require "erubis"

module Schott
  #Methods that standardize terraform invocation
  module Terraform
    include Schott::AzureCLI
    #Backend configuration template.
    #
    #This is not a file under templates for convenience
    BACKEND_TEMPLATE = <<-EOT
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-foundation"
    storage_account_name = "<%= project_name %>terraform"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    access_key           = "<%= access_key %>"
  }
}
  EOT
    #Invokes terraform in the correct context
    #
    #It changes in the tf_config directory and first executes 'terraform init'.
    #It then scans for any .tfvars files in the current and in the parent directtory and adds them to the command line.
    #
    #The user can pass additional options with tf_command_options, which are then added at the end of the commandline
    #
    #Expects the terraform command to be in the PATH
    def run_terraform(tf_command, tf_command_options, tf_config)
      tf_root = File.dirname(tf_config)
      Dir.chdir(tf_config) do
        init_terraform(tf_config)
        cmdline = "terraform #{tf_command} -var-file=#{Rake::FileList["*.tfvars", "#{tf_root}/*.tfvars"].join(" -var-file=")}  #{tf_command_options}"
        sh(cmdline)
      end
    end

    #Invokes 'terraform init'
    def init_terraform(tf_config)
      sh("terraform init")
    end

    #Performs validations in the project terraform space to check for missing configuration etc.
    #
    # Checks for the existense of a backend.tf (terraform backend configuration)
    def validate_tf_project(project_name, system_config)
      backend_file = File.join(system_config.base, system_config.azure_project, "#{project_name}-backend.tf")
      raise "Missing #{project_name}-backend.tf. Cannot access deployed state without it. Use rake bootstrap:backend to generate it" unless File.exist?(backend_file)
    end

    def generate_backend_config(system_config)
      backend_config = File.join(system_config.base, system_config.azure_project, "#{system_config.project_name}-backend.tf")
      if File.exist?(backend_config)
        puts "#{File.basename(backend_config)} already exists!"
      else
        storage_access_key = primary_storage_key("azuresandboxterraform", $configuration)
        template_params = {
          "project_name" => system_config.project_name,
          "access_key" => storage_access_key,
        }
        write_file(backend_config, Erubis::Eruby.new(BACKEND_TEMPLATE).result(template_params).gsub("\n", "\r\n"))
      end
      return backend_config
    end

    #Expects access_data to conform to the following Hash
    # {
    #   "appId"=> "",
    #   "displayName"=> "",
    #   "name"=> "",
    #   "password"=> "",
    #   "tenant"=> ""
    # }
    #which is the return value of AzureCLI.create_principal
    #
    #Creates a set of Azure Devops secret variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID)
    #to be used for authenticating terraform against Azure
    def create_terraform_authentication_variables(access_data, pipeline, system_config)
      variable_group_id = create_variable_group("TF", system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_secret_variable("ARM_CLIENT_ID", access_data["appId"], variable_group_id)
      run_command("Create ARM_CLIENT_ID", cmdline, system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_secret_variable("ARM_CLIENT_SECRET", access_data["password"], variable_group_id)
      run_command("Create ARM_CLIENT_SECRET", cmdline, system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_secret_variable("ARM_TENANT_ID", access_data["tenant"], variable_group_id)
      run_command("Create ARM_TENANT_ID", cmdline, system_config)
      return true
    end
  end
end
