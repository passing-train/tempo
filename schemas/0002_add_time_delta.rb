schema "0002" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
    integer32 :time_delta
  end
end
