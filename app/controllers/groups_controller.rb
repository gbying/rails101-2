class GroupsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :edit, :create, :destroy, :update]
  before_action :find_group_and_check_permission, only: [:edit, :update, :destroy]
  def index
    @groups = Group.all
  end
  def new
    @group = Group.new
  end
  def create
    @group = Group.new(group_params)
    @group.user = current_user
    if @group.save

      redirect_to groups_path
    else
      render :new
    end
  end
  def update
    find_group_and_check_permission
    if @group.update(group_params)
      redirect_to groups_path, notice: "Update Sucess"
    else
      render :edit
    end
  end
  def destroy
    find_group_and_check_permission
    @group.destroy
    flash[:alert] = "Group Deleted"
    redirect_to groups_path
  end
  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end
  def edit
    find_group_and_check_permission
  end
  def join
    @group = Group.find(params[:id])
      if !current_user.is_member_of?(@group)
        current_user.join!(@group)
        flash[:notice] = "加入本讨论组成功！"
      else
        flash[:warning] = "你已是本组成员！"
      end
    redirect_to group_path(@group)
  end
  def quit
    @group = Group.find(params[:id])

    if current_user.is_member_of?(group)
      current_user.quit!(@group)
      flash[:alert] = "你已退出本讨论组！"
    else
      flash[:warning] = "你不是本组成员！无需退出！"
    end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end

  def find_group_and_check_permission
    @group = Group.find(params[:id])

    if current_user != @group.user
      redirect_to root_path, alert: "You have no permission."
    end
  end
end
