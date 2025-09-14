# /projects
resources :projects do
  # /projects/:project_id/issue_notifications
  # 顯示特定專案中所有已訂閱的議題列表
  resources :issue_notifications, only: [:index]
end

# /issues
resources :issues do
  # /issues/:issue_id/issue_notification
  resource :issue_notification, only: [] do
    member do
      # POST /issues/:issue_id/issue_notification/subscribe
      # 訂閱特定議題的通知
      post :subscribe

      # DELETE /issues/:issue_id/issue_notification/unsubscribe
      # 取消訂閱特定議題的通知
      delete :unsubscribe
    end
  end
end 