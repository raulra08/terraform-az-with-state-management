module Gaudi
  module Configuration
    #This module provides getters for environment variables
    #
    #The reason we explicitly use getters instead of direct ENV[] accesses is that the methods
    #allow us to add validation code (e.g. check for nil values), defaults and also make the available variables visible in the documentation
    module EnvironmentOptions
      #Azure APP_ID
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def app_id
        return mandatory("APP_ID")
      end

      #Azure TENANT_ID
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def tenant_id
        return mandatory("TENANT_ID")
      end

      #Service principal application key
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def app_key
        return mandatory("APP_KEY")
      end

      #Project subscription ID
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def subscription_id
        return mandatory("SUBSCRIPTION_ID")
      end

      #Client ID for authenticating terraform
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def arm_client_id
        return mandatory("ARM_CLIENT_ID")
      end

      #Service principal secret for authenticating terraform
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def arm_client_secret
        return mandatory("ARM_CLIENT_SECRET")
      end

      #Subscripion ID for authenticating terraform
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def arm_subscription_id
        return mandatory("ARM_SUBSCRIPTION_ID")
      end

      #Tenant ID for authenticating terraform
      #
      #This is part of the sensitive data required to login to Azure
      #and the value to the environment should be provided by a secret variable
      def arm_tenant_id
        return mandatory("ARM_TENANT_ID")
      end
    end
  end
end
