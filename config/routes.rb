Rails.application.routes.draw do
    post "/api/threads/:board", to: "api#create_thread"
    get "/api/threads/:board", to: "api#list_recent_threads"
    put "/api/threads/:board", to: "api#report_thread"
    delete "/api/threads/:board", to: "api#delete_thread"

    post "/api/replies/:board", to: "api#reply_to_thread"
    get "/api/replies/:board", to: "api#list_all_thread_replies"
    put "/api/replies/:board", to: "api#report_reply"
    delete "/api/replies/:board", to: "api#delete_reply"
end
