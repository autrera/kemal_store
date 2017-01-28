require "kemal"

# logging false

macro admin_render(view_file_path)
  render {{view_file_path}}, "src/views/layouts/admin.ecr"
end

struct AdminOrderController
  def index
    admin_render "src/views/admin/orders/index.ecr"
  end

  def new
  end

  def create
  end

  def show(env)
    id = env.params.url["id"]
    admin_render "src/views/admin/orders/edit.ecr"
  end

  def edit(env)
  end

  def update(env)
  end

  def destroy(env)
  end
end

struct AdminProductController
  def index
    admin_render "src/views/admin/products/index.ecr"
  end

  def new
  end

  def create
  end

  def show(env)
    id = env.params.url["id"]
    admin_render "src/views/admin/products/edit.ecr"
  end

  def edit(env)
  end

  def update(env)
  end

  def destroy(env)
  end
end

macro resource(route_parts, resource_object)

  index_route_string = "/"
  {% for route, index in route_parts %}
    index_route_string += {{route}} + "/"
  {% end %}
  new_route_string = index_route_string + "new"
  show_route_string = index_route_string + ":id"
  edit_route_string = show_route_string + "/edit"

  get index_route_string do
    {{resource_object}}Controller.new.index
  end

  get new_route_string do
    {{resource_object}}Controller.new.new
  end

  post index_route_string do
    {{resource_object}}Controller.new.create
  end

  get show_route_string do |env|
    {{resource_object}}Controller.new.show(env)
  end

  get edit_route_string do |env|
    {{resource_object}}Controller.new.edit(env)
  end

  put show_route_string do |env|
    {{resource_object}}Controller.new.update(env)
  end

  patch show_route_string do |env|
    {{resource_object}}Controller.new.update(env)
  end

  delete show_route_string do |env|
    {{resource_object}}Controller.new.destroy(env)
  end

end

resource ["admin", "orders"], AdminOrder
resource ["admin", "products"], AdminProduct
# resource "/orders", Order

get "/" do
  "Hello World!"
end

Kemal.run
