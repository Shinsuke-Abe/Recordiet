# encoding: utf-8
class Admin::ConfirmsController < ApplicationController
	before_filter :authenticate_user!

	def show
		@user = current_user
	end
end
