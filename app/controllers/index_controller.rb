class IndexController < ApplicationController
  def show
    @member = Member.where(:username => params[:username]).first
    if not @member
      @member = Member.create(:username => params[:username])
      @member.update_karma
    end
    attrs = @member.attributes
    attrs[:percentile] = @member.percentile
    attrs[:month_percentile] = @member.percentile(:date=>true)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: attrs }
    end
  end
end
