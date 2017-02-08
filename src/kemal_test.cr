require "kemal"
require "db"
require "pg"

# logging false

def minify_css(*file_paths)
  current_dir = Dir.current
  contents = ""
  file_paths.each do |path|
    contents += File.read("#{current_dir}/public#{path}", "UTF-8")
  end
  File.write("#{current_dir}/public/css/minified.css", contents)
  return true
end

struct Product
  property id, organization_id, name, sku, stock, price

  def initialize(@id : Int32 = 0, @organization_id : Int32 = 0, @name : String = "", @sku : String = "", @stock : Int32 = 0, @price : Int32 = 0)
  end

  def is_valid
    if @id == 0
      return false
    end
    return true
  end
end

db = DB.open "postgres://localhost:5432/kemal_test"

def get_products(db)
  products = [] of Product
  db.query("SELECT id, organization_id, name, sku, stock, price FROM products") do |rs|
    rs.each do
      id, organization_id, name, sku, stock, price = rs.read(Int32, Int32, String, String, Int32, Int32)
      product = Product.new(id, organization_id, name, sku, stock, price)
      products.push(product)
    end
  end
  return products
end

def get_product(db, id)
  id, organization_id, name, sku, stock, price = db.query_one "SELECT id, organization_id, name, sku, stock, price FROM products WHERE id = $1", id, as: { Int32, Int32, String, String, Int32, Int32 }

  # db.query_one("SELECT id, organization_id, name, sku, stock, price FROM products") do |rs|
  #   rs.each do
  #     id, organization_id, name, sku, stock, price = rs.read(Int32, Int32, String, String, Int32, Int32)
  #     product = Product.new(id, organization_id, name, sku, stock, price)
  #     products.push(product)
  #   end
  # end

  product = Product.new(id, organization_id, name, sku, stock, price)
  return product
end

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

minify_css("/css/normalize.css", "/css/grid.css", "/css/ui.css", "/css/dashboard.css")

get "/" do
  "Hello World!"
end

get "/admin/products" do
  index_products = get_products(db)
  admin_render "src/views/admin/products/index.ecr"
end

get "/admin/products/new" do
  product = Product.new
  admin_render "src/views/admin/products/new.ecr"
end

post "/admin/products" do |env|
  name = env.params.body["product[name]"]
  sku = env.params.body["product[sku]"]
  stock = env.params.body["product[stock]"]
  price = env.params.body["product[price]"]

  result = db.exec "INSERT INTO products(organization_id, name, sku, stock, price) VALUES (1, $1, $2, $3, $4)", name, sku, stock, price
  env.redirect "/admin/products/"
end

get "/admin/products/:id/edit" do |env|
  product = get_product(db, env.params.url["id"])
  admin_render "src/views/admin/products/edit.ecr"
end

patch "/admin/products/:id" do |env|
  id = env.params.url["id"]
  name = env.params.body["product[name]"]
  sku = env.params.body["product[sku]"]
  stock = env.params.body["product[stock]"]
  price = env.params.body["product[price]"]

  result = db.exec "UPDATE products SET name = $2, sku = $3, stock = $4, price = $5 WHERE id = $1", id, name, sku, stock, price
  env.redirect "/admin/products/"
end

delete "/admin/products/:id" do |env|
  id = env.params.url["id"]

  result = db.exec "DELETE FROM products WHERE id = $1", id
  env.redirect "/admin/products/"
end

Kemal.run

db.close
