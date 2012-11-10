#encoding: utf-8
module WeightLogsHelper
  WEIGHT_LOG_NOT_FOUND = "履歴が未登録です。"
  ACHIEVE_MILESTONE = "目標を達成しました！おめでとうございます。\nご褒美は%sです、楽しんで下さい！"
  
  def achieve_message(reward)
    sprintf(ACHIEVE_MILESTONE, reward)
  end
end
