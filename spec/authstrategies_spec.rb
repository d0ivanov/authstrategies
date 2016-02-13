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

  it "Redirects existing users to /authenticated" do
    post "/login", {email: "test@abv.bg", password: "123456789"}
    expect(last_response.status).to be 200
  end

  it "Redirects non-existing users to /unauthenticated" do
    post "/login", {email: "nont_existent@abv.bg", password: "123456789"}
    expect(last_response.status).to be 401
  end
end
