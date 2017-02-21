require "kemal"
# require "kemal-session"
# require "kemal-csrf"

require "db"
require "pg"

# logging false
gzip true

# Load env params
env_params = {} of String => String
if File.exists? Dir.current + "/.env"
  lines = File.read_lines(Dir.current + "/.env", "UTF-8")
  lines.each do |line|
    line_parts = line.split('=')
    env_params[line_parts[0]] = line_parts[1]
  end
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

struct ProductImage
  property id, product_id, url, relevance

  def initialize(@id : Int32 = 0, @product_id : Int32 = 0, @url : String = "", @relevance : Int32 = 0)
  end
end

struct Category
  property id, organization_id, name

  def initialize(@id : Int32 = 0, @organization_id : Int32 = 0, @name : String = "")
  end

  def is_valid
    if @id == 0
      return false
    end
    return true
  end
end

def minify_assets(*file_paths, file_path : String)
  current_dir = Dir.current
  contents = ""
  file_paths.each do |path|
    contents += File.read("#{current_dir}/public#{path}", "UTF-8")
  end
  File.write("#{current_dir}/public#{file_path}", contents)
  return true
end

def get_categories(db)
  categories = [] of Category
  db.query("SELECT id, organization_id, name FROM categories") do |rs|
    rs.each do
      id, organization_id, name = rs.read(Int32, Int32, String)
      category = Category.new(id, organization_id, name)
      categories.push(category)
    end
  end
  return categories
end

def get_category(db, id)
  id, organization_id, name = db.query_one "SELECT id, organization_id, name FROM categories WHERE id = $1", id, as: { Int32, Int32, String }

  category = Category.new(id, organization_id, name)
  return category
end

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

def get_product_categories(db, product_id)
  categories = [] of Category
  db.query("SELECT category_id FROM categories_products WHERE product_id = $1", product_id) do |rs|
    rs.each do
      id = rs.read(Int32)
      category = Category.new(id)
      categories.push(category)
    end
  end
  return categories
end

def get_product(db, id)
  id, organization_id, name, sku, stock, price = db.query_one "SELECT id, organization_id, name, sku, stock, price FROM products WHERE id = $1", id, as: { Int32, Int32, String, String, Int32, Int32 }

  product = Product.new(id, organization_id, name, sku, stock, price)
  return product
end

macro admin_render(view_file_path)
  render {{view_file_path}}, "src/views/layouts/admin.ecr"
end

macro store_render(view_file_path)
  render {{view_file_path}}, "src/views/layouts/store.ecr"
end

minified_file_fingerprint = Time.new.epoch
dashboard_styles = "/css/dashboard.#{minified_file_fingerprint}.min.css"
store_styles = "/css/store.#{minified_file_fingerprint}.min.css"
minify_assets("/css/normalize.css", "/css/grid.css", "/css/ui.css", "/css/dashboard.css", file_path: dashboard_styles)
minify_assets("/css/normalize.css", "/css/grid.css", "/css/ui.css", "/css/store.css", file_path: store_styles)

#db = DB.open "postgres://localhost:5432/kemal_test"
db = DB.open env_params["DB_URL"]

get "/" do
  store_render "src/views/store/welcome/index.ecr"
end

get "/admin/categories" do
  categories = get_categories(db)
  admin_render "src/views/admin/categories/index.ecr"
end

get "/admin/categories/new" do
  category = Category.new
  admin_render "src/views/admin/categories/new.ecr"
end

post "/admin/categories" do |env|
  name = env.params.body["category[name]"]

  result = db.exec "INSERT INTO categories(organization_id, name) VALUES (1, $1)", name
  env.redirect "/admin/categories/"
end

get "/admin/categories/:id/edit" do |env|
  category = get_category(db, env.params.url["id"])
  admin_render "src/views/admin/categories/edit.ecr"
end

patch "/admin/categories/:id" do |env|
  id = env.params.url["id"]
  name = env.params.body["category[name]"]

  result = db.exec "UPDATE categories SET name = $2 WHERE id = $1", id, name
  env.redirect "/admin/categories/"
end

delete "/admin/categories/:id" do |env|
  id = env.params.url["id"]

  result = db.exec "DELETE FROM categories WHERE id = $1", id
  if result.rows_affected > 0
    db.exec "DELETE FROM categories_products WHERE category_id = $1", id
  end

  env.redirect "/admin/categories/"
end

get "/admin/products" do
  products = get_products(db)
  admin_render "src/views/admin/products/index.ecr"
end

get "/admin/products/new" do
  product = Product.new
  product_categories = [] of Category
  categories = get_categories(db)
  admin_render "src/views/admin/products/new.ecr"
end

post "/admin/products" do |env|
  name = env.params.body["product[name]"]
  sku = env.params.body["product[sku]"]
  stock = env.params.body["product[stock]"]
  price = env.params.body["product[price]"]
  product_categories = env.params.body.fetch_all("product[categories][]")

  result = db.exec "INSERT INTO products(organization_id, name, sku, stock, price) VALUES (1, $1, $2, $3, $4)", name, sku, stock, price
  if result.rows_affected > 0 && product_categories.empty? == false
    product_id = db.query_one "SELECT currval(pg_get_serial_sequence('products','id'))", as: { Int64 }
    product_categories.each do |product_category|
      db.exec "INSERT INTO categories_products(product_id, category_id) VALUES($1, $2)", product_id, product_category
    end
  end

  env.redirect "/admin/products/"
end

get "/admin/products/:id/edit" do |env|
  product = get_product(db, env.params.url["id"])
  product_categories = get_product_categories(db, product.id)
  categories = get_categories(db)
  admin_render "src/views/admin/products/edit.ecr"
end

patch "/admin/products/:id" do |env|
  product_id = env.params.url["id"]
  name = env.params.body["product[name]"]
  sku = env.params.body["product[sku]"]
  stock = env.params.body["product[stock]"]
  price = env.params.body["product[price]"]
  product_categories = env.params.body.fetch_all("product[categories][]")

  db.exec "UPDATE products SET name = $2, sku = $3, stock = $4, price = $5 WHERE id = $1", product_id, name, sku, stock, price
  db.exec "DELETE FROM categories_products WHERE product_id = $1", product_id
  # insert = db.exec "INSERT INTO categories_products(product_id, category_id) SELECT $1 id, x FROM unnest(ARRAY[$2]) x", product_id, product_categories.join(',')
  unless product_categories.empty?
    product_categories.each do |product_category|
      db.exec "INSERT INTO categories_products(product_id, category_id) VALUES($1, $2)", product_id, product_category
    end
  end

  env.redirect "/admin/products/"
end

delete "/admin/products/:id" do |env|
  product_id = env.params.url["id"]

  delete_product = db.exec "DELETE FROM products WHERE id = $1", product_id
  if delete_product.rows_affected > 0
    db.exec "DELETE FROM categories_products WHERE product_id = $1", product_id
  end

  env.redirect "/admin/products/"
end

get "/admin/products/:id/images" do |env|
  product_id = env.params.url["id"]
  product_images = [] of ProductImage
  db.query("
    SELECT id,
           url,
           relevance
    FROM product_images
    WHERE product_id = $1
    ORDER BY relevance ASC
    ", product_id) do |rs|
    rs.each do
      id, url, relevance = rs.read(Int32, String, Int32)
      product_image = ProductImage.new(id: id, url: url, relevance: relevance)
      product_images.push(product_image)
    end
  end
  admin_render "src/views/admin/products/images/index.ecr"
end

get "/admin/products/:id/images/new" do |env|
  product_id = env.params.url["id"]
  product_image = ProductImage.new
  admin_render "src/views/admin/products/images/new.ecr"
end

post "/admin/products/:id/images" do |env|
  log env.params.inspect
  # file = env.params.files["file"]
  # file_temp = file.tmpfile
  # file_path = File.join [Kemal.config.public_folder, "uploads/products/", file.filename]
  # File.open(file_path, "w") do |f|
  #   IO.copy(file, f)
  # end
  # "Upload ok"
end

Kemal.run
db.close

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
