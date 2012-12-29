# encoding: utf-8
class Admin::MenusController < ApplicationController
	before_filter :authenticate_user!
	before_filter :authenticate_admin!

	def show
		# do nothing
	end
end
