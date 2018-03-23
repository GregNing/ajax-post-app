class PostsController < ApplicationController
    before_action :authenticate_user!, :only => [:create, :destroy]
    def index
        #@posts = Post.order("id DESC").all    # 新贴文放前面
        @posts = Post.order("id DESC").limit(20)    
        if params[:max_id]
          @posts = @posts.where( "id < ?", params[:max_id])
        end
        #respond_to 可以让 Rails 根据 request 请求的格式(在 $ajax 中我们有指定了 dataType)，来回传不同格式
        respond_to do |format|
          format.html  # 如果客户端要求 HTML，则回传 index.html.erb
          format.js    # 如果客户端要求 JavaScript，回传 index.js.erb
        end
    end
    def create
     @post = Post.new(post_params)
     @post.user = current_user
     @post.save

    end

    def destroy
     @post = current_user.posts.find(params[:id]) # 只能删除自己的贴文
     @post.destroy
    #这里改成返回一段 JavaScript 字串代码，内容是 alert('ok');，实际测试看看，点删除：
    #一个 action 如果没有写明 redirect 或 render 的话，就会默认去找 action 名称的样板。于是这里就会去找 destroy.js.erb  
    #render :js => "alert('ok');"    
    render :json => { :id => @post.id }
    end
    
    def like
    @post = Post.find(params[:id])
    unless @post.find_like(current_user)  # 如果已经按讚过了，就略过不再新增
      Like.create( :user => current_user, :post => @post)
    end

    #redirect_to posts_path
    end

    def unlike
    @post = Post.find(params[:id])
    like = @post.find_like(current_user)
    like.destroy

    #redirect_to posts_path
    #共用同一個模板
    render "like"
    end
    
    protected

    def post_params
     params.require(:post).permit(:content)
    end
end
