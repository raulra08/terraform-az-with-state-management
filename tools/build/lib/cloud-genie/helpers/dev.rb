require_relative "az"

module Schott
  module DevResources
    include Schott::AzureCLI
    #Creates the Azure DevOps pipelines corresponding to the
    #YAML definition files under tools/ci/pipelines
    #
    #If the names match any existing pipeline the operation is skipped
    def create_pipelines(project_name, project_repository, system_config)
      pipelines = Rake::FileList["tools/ci/pipelines/*.yml"]
      existing_pipelines = project_pipelines(system_config)
      pipelines.each do |pipeline|
        pipeline_name = "#{project_name}-#{pipeline.pathmap("%n")}"
        if existing_pipelines.include?(pipeline_name)
          puts "#{pipeline_name} exists. Skipping creation."
        else
          puts "Creating #{pipeline_name}."
          create_pipeline(pipeline_name, pipeline, project_repository, system_config)
        end
      end

      return pipelines.map { |pipeline| "#{project_name}-#{pipeline.pathmap("%n")}" }
    end
  end
end
