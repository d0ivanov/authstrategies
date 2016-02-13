require "spec_helper"

describe "AuthStrategies" do
  before :all do
    app.database.connection.execute("
      INSERT INTO
        users (email, password_hash)
      VALUES
        ('test@abv.bg', '$2a$10$Ri810wkDDqXRcexl81LSGu2J7ZuW4m9HSq0wBTAik1VSO7x5zsj5i')"
    )
  end

  after :all do
    app.database.connection.execute("DELETE FROM users;")
  end

  it "The response code afer an authentication of an existing user is 200" do
    post "/login", {email: "test@abv.bg", password: "123456789"}
    expect(last_response.status).to be 200
  end

  it "The response code afet an authentication of non-existing user is 401" do
    post "/login", {email: "nont_existent@abv.bg", password: "123456789"}
    expect(last_response.status).to be 401
  end

  it "After authenticating users can view protected links" do
    post "/login", {email: "test@abv.bg", password: "123456789"}
    get "/authenticated"
    expect(last_response.body).to eq "test@abv.bg"
  end

  it "Can logout" do
    post "/login", {email: "test@abv.bg", password: "123456789"}
    p last_response.body
    get "/authenticated"
    expect(last_response.body).to eq "test@abv.bg"

    post "/logout"
    get "/authenticated"

    expect(last_response.body).to eq ""
  end

  it "Can not view protected links when not logged in" do
    get "/authenticated"
    follow_redirect!

    expect(last_request.path_info).to eq "/unauthenticated"
  end
end
