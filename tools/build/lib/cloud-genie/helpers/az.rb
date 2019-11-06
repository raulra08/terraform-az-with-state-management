require_relative "execution"
require "json"

module Schott
  #Azure CLI commands that are needed for project tasks.
  #
  #The methods in this module define the necessary commandlines
  #and ensure invocation follows the project conventions
  #
  #All commands except for azure_principal_login assume that the Azure CLI client
  #has been authenticated and has the correct access rights.
  module AzureCLI
    include Schott::Execution

    module Commandlines
      #Logs in to Azure as the service principal
      def self.service_login(app_id, app_key, tenant_id)
        "az login --service-principal --username #{app_id} --password #{app_key} --tenant #{tenant_id}"
      end

      #Set the suscription ID to the one used by the project
      def self.set_subscription(system_config)
        "az account set --subscription #{system_config.subscription_id}"
      end

      #Creates a service principal
      def self.create_principal(principal_name)
        "az ad sp create-for-rbac --name #{principal_name}"
      end

      #Resets the service principal's credentials
      def self.reset_principal()
        "az ad sp credential reset --name #{system_config.app_id}"
      end

      def self.delete_principal(principal_name)
        "az ad sp delete --id #{principal_name}"
      end

      def self.delete_resource_group(group_name)
        "az group delete --yes --name #{group_name}"
      end

      def self.resource_group_exists?(group_name)
        "az group exists --name #{group_name}"
      end

      def self.create_pipeline(pipeline_name, pipeline_path, repository)
        "az pipelines create --name \"#{pipeline_name}\" --branch master --yml-path \"#{pipeline_path}\" --repository #{repository} --skip-run"
      end

      def self.storage_keys(storage_account)
        "az storage account keys list --account-name #{storage_account}"
      end

      def self.list_pipelines()
        "az pipelines list"
      end

      def self.create_variable_group(group_name)
        "az pipelines variable-group create --name #{group_name} --variables GROUP=#{group_name} --authorize true"
      end

      def self.create_secret_variable(varname, varvalue, vargroup)
        "az pipelines variable-group variable create --name #{varname} --value #{varvalue} --group-id #{vargroup} --secret true"
      end
    end

    #Logs in the Azure CLI using the credentials for a service principal
    #accessible through Gaudi::Configuration::EnvironmentOptions.app_id
    #Gaudi::Configuration::EnvironmentOptions.app_key and Gaudi::Configuration::EnvironmentOptions.tenant_id
    def azure_principal_login(system_config)
      cmdline = Schott::AzureCLI::Commandlines.service_login(system_config.app_id, system_config.app_key, system_config.tenant_id)
      cmd = run_command("Azure login", cmdline, system_config)
    end

    #Creates a service principal
    def create_principal(system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_principal(system_config.azure_principal)
      cmd = run_command("Create #{system_config.azure_principal}", cmdline, system_config)
      return JSON.load(cmd.output)
    end

    #Delete the resource group with _group_name_
    def delete_resource_group(group_name)
      cmdline = Schott::AzureCLI::Commandlines.delete_resource_group(group_name)
      sh(cmdline)
    end

    #Query the existence of a resource group
    def resource_group_exists?(group_name, system_config)
      cmdline = Schott::AzureCLI::Commandlines.resource_group_exists?(group_name)
      cmd = run_command("#{group_name} exists", cmdline, system_config)
      return cmd.output.chomp == "true"
    end

    #Returns the primary access key for the given storage account
    def primary_storage_key(storage_account, system_config)
      cmdline = Schott::AzureCLI::Commandlines.storage_keys(storage_account)
      cmd = run_command("Retrieve #{storage_account} keys", cmdline, system_config)
      keys = JSON.load(cmd.output)
      return keys.first["value"]
    end

    def create_variable_group(group_name, system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_variable_group(group_name)
      cmd = run_command("Create #{group_name}", cmdline, system_config)
      return JSON.load(cmd.output)["id"]
    end

    #Expects access_data to conform to the following Hash
    # {
    #   "appId"=> "",
    #   "displayName"=> "",
    #   "name"=> "",
    #   "password"=> "",
    #   "tenant"=> ""
    # }
    #which is the return value of create_principal
    #
    #Creates a set of Azure Devops secret variables (APP_ID, TENANT_ID, APP_KEY)
    #to be used for authenticating az against Azure
    def create_az_authentication_variables(access_data, pipeline, system_config)
      variable_group_id = create_variable_group("AZ", system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_secret_variable("APP_ID", access_data["appId"], variable_group_id)
      run_command("Create APP_ID", cmdline, system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_secret_variable("TENANT_ID", access_data["tenant"], variable_group_id)
      run_command("Create TENANT_ID", cmdline, system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_secret_variable("APP_KEY", access_data["password"], variable_group_id)
      run_command("Create APP_KEY", cmdline, system_config)
      return true
    end

    #Create an Azure DevOps build pipeline
    # pipeline_path - the path to the YAML file relative to the workspace root
    # repository - the clone/fetch URL of the git repository containing the YAML definition
    def create_pipeline(pipeline_name, pipeline_path, repository, system_config)
      cmdline = Schott::AzureCLI::Commandlines.create_pipeline(pipeline_name, pipeline_path, repository)
      cmd = run_command("Create #{pipeline_name}", cmdline, system_config)
      return cmd.success?
    end

    def project_pipelines(system_config)
      cmdline = Schott::AzureCLI::Commandlines.list_pipelines()
      cmd = run_command("List pipelines", cmdline, system_config)
      pipeline_metadata = JSON.load(cmd.output)
      return pipeline_metadata.map { |pip| pip["name"] }
    end
  end
end
