#encoding: utf-8
module WeightLogsHelper
  
  def achieve_message(reward)
    sprintf(application_message(:achieve_milestone), reward)
  end
end
