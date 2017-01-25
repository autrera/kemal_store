require "kemal"

# logging false

macro admin_render(view_file_path)
  render "#{{{ view_file_path }}}", "src/views/layouts/admin.ecr"
end

struct OrderController
  def index
    admin_render "src/views/admin/orders/index.ecr"
  end
end

macro resource(resource_route, resource_object)
  get "/{{resource_route}}" do
    {{resource_object}}Controller.new.index
  end

  get "/{{resource_route}}/:id" do
    {{resource_object}}Controller.new.index
  end
end

resource admin/orders, Order

get "/" do
  "Hello World!"
end

Kemal.run
