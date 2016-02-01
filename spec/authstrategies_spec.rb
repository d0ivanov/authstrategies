require "spec_helper.rb"
require "authstrategies"

describe "AuthStrategies" do
  it "Redirects existing users to /authenticated" do
    post "/login", {username: "test", password: "pass"}

    follow_redirect!
    expect(last_request.path_info).to be == "/authenticated"
  end

  it "Redirects non-existing users to /unauthenticated" do
    post "/login", {username: "test5", password: "pass"}

    follow_redirect!
    expect(last_request.path_info).to be == "/unauthenticated"
  end
end
