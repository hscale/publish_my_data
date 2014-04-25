    
    config.to_prepare do
      # include only the ApplicationHelper module in the PMD engine
      PublishMyData::ApplicationController.helper ApplicationHelper
      # # include all helpers from your application into the PMD engine
      # PublishMyData::ApplicationController.helper YourApp::Application.helpers
    end
    
