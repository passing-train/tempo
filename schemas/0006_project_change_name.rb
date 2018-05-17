schema "0006" do
  entity "Entry" do
    string :title, optional: false
    datetime :created_at
    integer32 :time_delta
    boolean :last_in_block, default: true
    integer32 :customer_id, optional: true
    string :project_id, optional: true
    float :extra_time, optional: true
    belongs_to :customer
  end

  entity "Customer" do
    string :name, optional: false
    integer32 :customer_id, optional: false
    has_many :entries
    has_many :projects
  end

  entity "Project" do
    string :project_id, optional: false
    has_many :entries
    belongs_to :customer
  end
end
