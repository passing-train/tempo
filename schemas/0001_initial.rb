schema "0001" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
  end
end
