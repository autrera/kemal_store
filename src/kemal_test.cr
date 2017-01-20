require "kemal"

# logging false

macro admin_render(view_file_path)
  render "#{{{ view_file_path }}}", "src/views/layouts/admin.ecr"
end

struct AdminController
  def index
    admin_render "src/views/admin/orders/index.ecr"
  end
end

macro resource(resource_name, resource_name_single)
  get "/{{resource_name}}" do
    {{resource_name_single}}Controller.new.index
  end

end

resource admin, Admin

get "/" do
  "Hello World!"
end

# get "/admin" do
#   admin_render "src/views/admin/orders/index.ecr"
# end

Kemal.run
