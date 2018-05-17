schema "0003" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
    integer32 :time_delta
    boolean :last_in_block, default: true
  end
end
