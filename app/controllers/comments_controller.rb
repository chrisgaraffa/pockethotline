class CommentsController < ApplicationController
  before_action :require_login

  # POST /comments
  # POST /comments.json
  def create
    @call = Call.find(params[:call_id])
    @comment = current_user.comments.new(comment_params)
    @comment.call = @call

    respond_to do |format|
      if @comment.save
        #@comment.delay.notify(url_for(activity_url(@activity))) #Coming back to the notifications

        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
        format.js { head :bad_request }
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
