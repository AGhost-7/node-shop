CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  "name" VarChar(45) NOT NULL,
  "password" TEXT NOT NULL,
  "email" TEXT NOT NULL
);

CREATE TABLE tokens(
  value CHAR(128) PRIMARY KEY,
  ip VarChar(30) NOT NULL,
  user_id INT NOT NULL
);

-- Could add a description and images, but meh.
CREATE TABLE products(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(2) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  CHECK (quantity >= 1),
  CHECK (price > 0)
);

CREATE TABLE purchases(
  id SERIAL PRIMARY KEY,
  stamp TIMESTAMP NOT NULL,
  user_id INT NOT NULL REFERENCES users(id)
);

-- Products either purchased or in cart.
CREATE TABLE held_products(
  id SERIAL PRIMARY KEY,
  quantity INT NOT NULL,
  purchased BOOLEAN NOT NULL DEFAULT FALSE,
  purchase_id INT NOT NULL REFERENCES purchases(id),
  user_id INT NOT NULL REFERENCES users(id),
  product_id INT REFERENCES products(id)
);
