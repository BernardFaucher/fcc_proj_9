class ApiController < ActionController::API
    def create_thread
        @thread = Topic.new({
            board: params[:board],
            text: params[:text],
            delete_password: params[:delete_password]
        })
        if @thread.save
            render json: {
                "_id" => @thread._id,
                "text" => @thread.text,
                "created_on" => @thread.created_on,
                "bumped_on" => @thread.bumped_on,
                "reported" => @thread.reported,
                "delete_password" => @thread.delete_password,
                "replies" => []
            }
        else
            render plain: "Invalid Thread Params"
        end
    end

    def list_recent_threads
        render json: Topic.latest_threads_in_board(params[:board]).map{ |thread| {
            "_id" => thread._id,
            "text" => thread.text,
            "created_on" => thread.created_on,
            "bumped_on" => thread.bumped_on,
            "replies" => thread.replies.order(updated_at: :desc).limit(3).map{ |reply| {
                "_id" => reply._id,
                "text" => reply.text,
                "created_on" => reply.created_on,
            } }
        } }
    end

    def report_thread
        @thread = Topic.where({
            board: params[:board],
            id: params[:thread_id]
        }).first
        begin
            @thread.update(reported: true)
            render plain: "success"
        rescue NoMethodError
            render plain: "No such thread"
        end
    end

    def delete_thread
        @thread = Topic.where({
            board: params[:board],
            id: params[:thread_id]
        }).first
        if @thread.nil?
            render plain: "No such thread"
        elsif @thread.delete_password != params[:delete_password]
            render plain: "incorrect password"
        else
            @thread.replies.destroy_all
            @thread.delete
            render plain: "success"
        end
    end

    def reply_to_thread
        @thread = Topic.where({
            board: params[:board],
            id: params[:thread_id]
        }).first
        if @thread.nil?
            render plain: "No such thread"
        elsif @thread.replies.create({text: params[:text], delete_password: params[:delete_password]})
            @thread.update(updated_at: DateTime.now)
            render json: {
                "_id" => @thread._id,
                "text" => @thread.text,
                "created_on" => @thread.created_on,
                "bumped_on" => @thread.bumped_on,
                "replies" => @thread.replies.order(updated_at: :desc).map.with_index{ |reply, index| {
                    "_id" => reply._id,
                    "text" => reply.text,
                    "created_on" => reply.created_on,
                    "reported" => reply.reported,
                    "delete_password" => index == 0 ? params[:delete_password] : nil
                } }
            }
        else
            render plain: "Invalid Reply Params"
        end
    end

    def list_all_thread_replies
        @thread = Topic.where({
            board: params[:board],
            id: params[:thread_id]
        }).first
        if @thread.nil?
            render plain: "No such thread"
        else
            render json: {
                "_id" => @thread._id,
                "text" => @thread.text,
                "created_on" => @thread.created_on,
                "bumped_on" => @thread.bumped_on,
                "replies" => @thread.replies.order(updated_at: :desc).map{ |reply| {
                    "_id" => reply._id,
                    "text" => reply.text,
                    "created_on" => reply.created_on,
                } }
            }
        end
    end

    def report_reply
        begin
            @reply = Reply.find(params[:reply_id])
            @reply.update(reported: true)
            render plain: "success"
        rescue ActiveRecord::RecordNotFound
            render plain: "No such reply"
        end
    end

    def delete_reply
        begin
            @reply = Reply.find(params[:reply_id])
            if @reply.delete_password != params[:delete_password]
                render plain: "incorrect password"
            else
                @reply.update(text: "[deleted]")
                render plain: "success"
            end
        rescue ActiveRecord::RecordNotFound
            render plain: "No such reply"
        end
    end
end
