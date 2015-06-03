CREATE TYPE purchase_total AS (
  subtotal NUMERIC(10, 2),
  tax  NUMERIC(10, 2),
  total  NUMERIC(10, 2)
);


CREATE OR REPLACE FUNCTION cart_total(
	subt NUMERIC(10 , 2)
	--OUT subtotal NUMERIC(10, 2),
	--OUT tax  NUMERIC(10, 2),
	--OUT total  NUMERIC(10, 2)
) RETURNS purchase_total AS
$$
DECLARE
  r purchase_total;
BEGIN

	r.subtotal := subt;
	r.tax := round(r.subtotal * 0.13, 2);
	r.total := r.tax + r.subtotal;
  RETURN r;
END
$$language plpgsql;
