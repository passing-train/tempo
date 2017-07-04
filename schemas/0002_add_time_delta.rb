schema "0002 add_time_delta" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
    integer32 :time_delta
  end
end
