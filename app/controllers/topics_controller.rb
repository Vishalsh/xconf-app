class TopicsController < ApplicationController

  def index
    @topics = Topic.all.order('id desc')
    @current_user = session[:cas_user]
  end

  def new
    @topic = Topic.new
  end

  def show
    @topic = Topic.find(params[:id])
    respond_to do |format|
      format.html { render partial: 'topic' }
    end
  end

  def create
    @topic = Topic.new(params[:topic].permit(:title, :category, :description))
    if @topic.save_with_registerer session[:cas_user]
      redirect_to topics_path, {notice: 'You have successfully registered the topic'}
    else
      render 'new'
    end
  end

  def vote_for
    topic = Topic.find(params[:id])
    current_user = session[:cas_user]

    if topic.speakers.pluck(:name).include?(current_user)
      render text: "Sorry, You Can't vote for your own topic", status: :unprocessable_entity
    elsif topic.voters.pluck(:name).include?(current_user)
      render text: "Sorry, You can't vote more than once to the same topic", status: :unprocessable_entity
    else
      topic.voters << User.find_or_create_by(name: current_user)
      render nothing: true, status: :ok
    end
  end

  def get_speakers
    @topic_id = params[:id]
    @speakers = Topic.find(@topic_id).speakers
    respond_to do |format|
      format.html { render partial: 'speakers_list' }
    end
  end

  def add_speakers
    topic = Topic.find(params[:id])
    has_added, already_added_speakers = topic.add_speakers_to_topic params[:speakers]
    if has_added
      render nothing: true, status: :ok
    else
      render text: already_added_speakers , status: :unprocessable_entity
    end
  end

  def destroy
    topic = Topic.find(params[:id])
    if topic.delete
      redirect_to topics_path
    end
  end

end
