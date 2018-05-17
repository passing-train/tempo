schema "0004" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
    integer32 :time_delta
    boolean :last_in_block, default: true
    integer32 :customer_id, optional: true
    string :project_id, optional: true
    float :extra_time, optional: true
  end
end
