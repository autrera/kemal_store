require "kemal"

#logging false

macro admin_render(view_file_path)
  render "#{{{ view_file_path }}}", "src/views/layouts/admin.ecr"
end

get "/" do
  "Hello World!"
end

get "/admin" do
  name = "Aldo"

  admin_render "src/views/admin/render.ecr"
end

Kemal.run

