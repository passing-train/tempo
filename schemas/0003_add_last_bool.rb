schema "0003 add_last_bool" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
    integer32 :time_delta
    boolean :last_in_block, default: true
  end
end
