module Controller
  class ApiRootController < BaseController
    get prefix_route("/") do
      json_response 200,
                    links: {
                      documentation: {
                        href: "https://raw.githubusercontent.com/communitiesuk/epb-auth-server/master/config/apidoc.yml",
                      },
                    }
    end
  end
end
