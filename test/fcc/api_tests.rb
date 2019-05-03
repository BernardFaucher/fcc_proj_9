require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
    # CRUD: THREADS
    test "POST /api/threads/:board" do
        # LEGIT
        post "/api/threads/test", params: {text: "seems legit", delete_password: "sekret"}
        assert_not_nil(JSON.parse(response.body)["_id"])
        assert_not_nil(JSON.parse(response.body)["created_on"])
        assert_not_nil(JSON.parse(response.body)["bumped_on"])
        assert_equal("seems legit", JSON.parse(response.body)["text"])
        assert_equal(false, JSON.parse(response.body)["reported"])
        assert_equal("sekret", JSON.parse(response.body)["delete_password"])
        assert_equal([], JSON.parse(response.body)["replies"])
        # NOT LEGIT
        post "/api/threads/test", params: {text: nil, delete_password: "not_cool_man"}
        assert_equal("Invalid Thread Params", response.body)
        assert_raise(ActionController::RoutingError) {post "/api/threads/", params: {text: "missing board", delete_password: "not_cool_man"}}
    end

    test "GET /api/threads/:board" do
        15.times do |t|
            @thread = Topic.create(text: "Thread #{t}", board: "test")
            (t % 5).times do |r|
                @thread.replies.create(text: "Reply #{r} to Thread #{t}")
            end
        end

        get "/api/threads/test"
        # has 15 threads, should show latest 10
        assert_equal(10, JSON.parse(response.body).length)
        assert_equal("Thread 14", JSON.parse(response.body).first["text"])
        # has 4 replies, should show latest 3
        assert_equal(3, JSON.parse(response.body).first["replies"].count)
        assert_equal("Reply 3 to Thread 14", JSON.parse(response.body).first["replies"].first["text"])
    end

    test "PUT /api/threads/:board" do
        # LEGIT
        @thread = Topic.create(text: "Test Thread", board: "test")
        assert_equal(false, @thread.reported)
        put "/api/threads/test", params: {thread_id: @thread.id}
        @thread = Topic.find(@thread.id)
        assert_equal(true, @thread.reported)
        assert_equal("success", response.body)
        # NOT LEGIT
        put "/api/threads/test", params: {thread_id: "totally_not_legit_id"}
        assert_equal("No such thread", response.body)
    end

    test "DELETE /api/threads/:board" do
        # No Delete Password
        @thread = Topic.create(text: "A Thread", board: "test")
        delete "/api/threads/test", params: {thread_id: @thread.id}
        assert_equal(true, Topic.where(id: @thread.id).empty?)
        assert_equal("success", response.body)
        # Incorrect Delete Password
        @thread = Topic.create(text: "A Thread", board: "test", delete_password: "password")
        delete "/api/threads/test", params: {thread_id: @thread.id, delete_password: "abc123"}
        assert_equal(false, Topic.where(id: @thread.id).empty?)
        assert_equal("incorrect password", response.body)
        # Correct Delete Password, Thread w/Reply
        @thread = Topic.create(text: "A Thread", board: "test", delete_password: "password")
        @reply = @thread.replies.create(text: "A Reply")
        delete "/api/threads/test", params: {thread_id: @thread.id, delete_password: "password"}
        assert_equal(true, Topic.where(id: @thread.id).empty?)
        assert_equal(true, Reply.where(id: @reply.id).empty?)
        assert_equal("success", response.body)
    end
    # CRUD: REPLIES
    test "POST /api/replies/:board" do
        # LEGIT
        @thread = Topic.create(text: "A Thread", board: "test")
        post "/api/replies/test", params: {text: "A Reply", thread_id: @thread.id, delete_password: "password"}
        assert_equal("A Reply", JSON.parse(response.body)["replies"].first["text"])
        assert_equal("password", JSON.parse(response.body)["replies"].first["delete_password"])
        post "/api/replies/test", params: {text: "Another Reply", thread_id: @thread.id, delete_password: "password"}
        assert_equal("Another Reply", JSON.parse(response.body)["replies"].first["text"])
        assert_equal("password", JSON.parse(response.body)["replies"].first["delete_password"])
        # shows password of reply w/o bleeding all passwords
        assert_nil(JSON.parse(response.body)["replies"].last["delete_password"])
        # NOT LEGIT
        post "/api/replies/test", params: {text: "A Reply", thread_id: "blurghhhh", delete_password: "password"}
        assert_equal("No such thread", response.body)
    end

    test "GET /api/replies/:board" do
        @thread = Topic.create(text: "A Thread", board: "test")
        5.times do |t|
            @thread.replies.create(text: "Reply #{t+1}", delete_password: "123456")
        end
        get "/api/replies/test", params: {thread_id: @thread.id}
        assert_equal(5, JSON.parse(response.body)["replies"].count)
        # Ordered correctly
        assert_equal("Reply 5", JSON.parse(response.body)["replies"].first["text"])
        # Sanitized correctly
        assert_nil(JSON.parse(response.body)["replies"].first["delete_password"])
        assert_nil(JSON.parse(response.body)["replies"].first["reported"])
        get "/api/replies/test", params: {thread_id: "beep_boop"}
        assert_equal("No such thread", response.body)
    end

    test "PUT /api/replies/:board" do
        # LEGIT
        @thread = Topic.create(text: "A Thread", board: "test")
        @reply = @thread.replies.create(text: "NSFW Reply")
        put "/api/replies/test", params: {reply_id: @reply.id}
        @reply = Reply.find(@reply.id)
        assert_equal(true, @reply.reported)
        assert_equal("success", response.body)
        # NOT LEGIT
        put "/api/replies/test", params: {reply_id: "gadzooks"}
        assert_equal("No such reply", response.body)
    end

    test "DELETE /api/replies/:board" do
        # LEGIT NO PASSWORD
        @thread = Topic.create(text: "A Thread", board: "test")
        @reply = @thread.replies.create(text: "Throwaway Reply")
        delete "/api/replies/test", params: {reply_id: @reply.id}
        @reply = Reply.find(@reply.id)
        assert_equal("[deleted]", @reply.text)
        assert_equal("success", response.body)
        # INCORRECT PASSWORD
        @thread = Topic.create(text: "A Thread", board: "test")
        @reply = @thread.replies.create(text: "Throwaway Reply", delete_password: "yeahyeah")
        delete "/api/replies/test", params: {reply_id: @reply.id, delete_password: "nahnah"}
        @reply = Reply.find(@reply.id)
        assert_equal("Throwaway Reply", @reply.text)
        assert_equal("incorrect password", response.body)
        # CORRECT PASSWORD
        @thread = Topic.create(text: "A Thread", board: "test")
        @reply = @thread.replies.create(text: "Throwaway Reply", delete_password: "yeahyeah")
        delete "/api/replies/test", params: {reply_id: @reply.id, delete_password: "yeahyeah"}
        @reply = Reply.find(@reply.id)
        assert_equal("[deleted]", @reply.text)
        assert_equal("success", response.body)
        # NOT LEGIT
        delete "/api/replies/test", params: {reply_id: "qwerty"}
        assert_equal("No such reply", response.body)
    end
end
