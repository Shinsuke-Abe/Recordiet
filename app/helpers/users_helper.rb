module UsersHelper
  def weight_log_url(log_id)
    "/user/weight_logs/" + log_id.to_s
  end
end
