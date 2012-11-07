class MilestonesController < ApplicationController
  # /user/milestone/new
  def new
    @milestone = Milestone.new
  end
end
