# encoding: utf-8
module MenusHelper
  # TODO コントローラに寄せ手ヘルパメソッド化する？
  def current_weight_log
    @weight_log ||= WeightLog.find(params[:weight_log_id])
  end
end
