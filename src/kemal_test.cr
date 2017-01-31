require "kemal"
require "db"
require "pg"

# logging false

db = DB.open "postgres://localhost:5432/kemal_test"

macro admin_render(view_file_path)
  render {{view_file_path}}, "src/views/layouts/admin.ecr"
end

# macro resource(route_parts, resource_object)
#
#   index_route_string = "/"
#   {% for route, index in route_parts %}
#     index_route_string += {{route}} + "/"
#   {% end %}
#   new_route_string = index_route_string + "new"
#   show_route_string = index_route_string + ":id"
#   edit_route_string = show_route_string + "/edit"
#
#   get index_route_string do
#     {{resource_object}}Controller.new.index(db)
#   end
#
#   get new_route_string do
#     {{resource_object}}Controller.new.new
#   end
#
#   post index_route_string do
#     {{resource_object}}Controller.new.create
#   end
#
#   get show_route_string do |env|
#     {{resource_object}}Controller.new.show(env)
#   end
#
#   get edit_route_string do |env|
#     {{resource_object}}Controller.new.edit(env)
#   end
#
#   put show_route_string do |env|
#     {{resource_object}}Controller.new.update(env)
#   end
#
#   patch show_route_string do |env|
#     {{resource_object}}Controller.new.update(env)
#   end
#
#   delete show_route_string do |env|
#     {{resource_object}}Controller.new.destroy(env)
#   end
#
# end
#
# struct AdminOrderController
#   def index(db)
#     admin_render "src/views/admin/orders/index.ecr"
#   end
#
#   def new
#   end
#
#   def create
#   end
#
#   def show(env)
#     id = env.params.url["id"]
#     admin_render "src/views/admin/orders/edit.ecr"
#   end
#
#   def edit(env)
#   end
#
#   def update(env)
#   end
#
#   def destroy(env)
#   end
# end
#
# struct AdminProductController
#   def index(db)
#     organizations = [] of NamedTuple(id: Int32, name: String)
#     db.query("SELECT id, name FROM organizations") do |rs|
#       rs.each do
#         id = rs.read(Int32)
#         name = rs.read(String)
#         organizations.push({ id: id, name: name })
#       end
#     end
#     admin_render "src/views/admin/products/index.ecr"
#   end
#
#   def new
#   end
#
#   def create
#   end
#
#   def show(env)
#     id = env.params.url["id"]
#     admin_render "src/views/admin/products/edit.ecr"
#   end
#
#   def edit(env)
#   end
#
#   def update(env)
#   end
#
#   def destroy(env)
#   end
# end
#
# resource ["admin", "orders"], AdminOrder
# resource ["admin", "products"], AdminProduct

get "/" do
  "Hello World!"
end

get "/admin/products" do
  organizations = [] of NamedTuple(id: Int32, name: String)
  db.query("SELECT id, name FROM products") do |rs|
    rs.each do
      id = rs.read(Int32)
      name = rs.read(String)
      organizations.push({ id: id, name: name })
    end
  end
  admin_render "src/views/admin/products/index.ecr"
end

Kemal.run

db.close
