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
) RETURNS TABLE AS
$$
DECLARE
  subtotal NUMERIC(10, 2);
  tax NUMERIC(10, 2);
  total NUMERIC(10, 2);
  r purchase_total;
BEGIN

	subtotal := subt;
	tax := round(subtotal * 0.13, 2);
	total := tax + subtotal;
  RETURN QUERY SELECT (subtotal AS subtotal, tax AS tax, total AS total);
END
$$language plpgsql;
