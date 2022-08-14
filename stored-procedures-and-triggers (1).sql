-- Trigger to update the restaurant overall rating when review gets modified or added
CREATE TRIGGER update_restaurant_rating
    AFTER DELETE OR INSERT OR UPDATE OF RATING
    ON REVIEWS
    FOR EACH ROW
DECLARE
    no_of_ratings number;
    total_rating  number;
    new_rating    number;
BEGIN
    /* assume that RATING is non-null field */
    SELECT COUNT(*) INTO no_of_ratings FROM REVIEWS RW WHERE RW.RESTAURANTID = :OLD.RESTAURANTID;
    SELECT SUM(RATING) INTO total_rating FROM REVIEWS RW WHERE RW.RESTAURANTID = :OLD.RESTAURANTID;
    new_rating := (total_rating / no_of_ratings);
    UPDATE RESTAURANT
    SET rating = new_rating
    WHERE RESTAURANTID = :OLD.RESTAURANTID;
END;

-- Trigger to update the restaurant overall rating when review gets modified or added using all conditions
CREATE OR REPLACE TRIGGER update_restaurant_rating_v2
    AFTER DELETE OR INSERT OR UPDATE OF RATING
    ON REVIEWS
    FOR EACH ROW
DECLARE
    no_of_ratings  number;
    rating_diff    number;
    curr_rating    number;
    updated_rating number;
BEGIN
    /* assume that RATING is non-null field */
    SELECT COUNT(*) INTO no_of_ratings FROM REVIEWS RW WHERE RW.RESTAURANTID = :OLD.RESTAURANTID;
    SELECT RATING INTO curr_rating FROM RESTAURANT WHERE RESTAURANTID = :OLD.RESTAURANTID;

    IF DELETING THEN
        updated_rating := (curr_rating * (no_of_ratings + 1) - :OLD.rating) / no_of_ratings;
    END IF;

    IF INSERTING THEN
        updated_rating := (curr_rating * (no_of_ratings - 1) + :NEW.rating) / no_of_ratings;
    END IF;

    IF UPDATING THEN
        rating_diff := :NEW.RATING - :OLD.RATING;
        updated_rating := (curr_rating * (no_of_ratings) + rating_diff) / no_of_ratings;
    END IF;

    UPDATE RESTAURANT
    SET rating = updated_rating
    WHERE RESTAURANTID = :OLD.RESTAURANTID;
END;


-- Trigger to update the fullfilled orders by a door dasher whenever a order is delivered
CREATE OR REPLACE TRIGGER update_fulfilled_orders
    AFTER
        UPDATE OF DeliveryStatus
    ON ORDERDELIVERY
    FOR EACH ROW
DECLARE
    FULFILLED number;
BEGIN
    FULFILLED := 1;
    IF UPDATING AND :new.DeliveryStatus = FULFILLED THEN
        UPDATE DoorDasher DD
        SET OrdersFulfilled = OrdersFulfilled + 1
        WHERE DD.SSN = :new.DoorDasherSSN;
    END IF;
END;


-- Increasing the food price by percentage of amount
CREATE OR REPLACE PROCEDURE increase_food_price_by_percent(
    rest_id IN RESTAURANT.RESTAURANTID%TYPE,
    percentage IN number
) AS
    thisFood FOOD%ROWTYPE;
    CURSOR FoodCur IS
        SELECT F.*
        FROM RESTAURANT R,
             FOOD F
        WHERE R.RESTAURANTID = rest_id
          AND R.RESTAURANTID = F.RESTAURANTID
            FOR UPDATE;

BEGIN
    OPEN FoodCur;
    LOOP
        FETCH FoodCur INTO thisFood;
        EXIT WHEN (FoodCur%NOTFOUND);
        UPDATE FOOD
        SET PRICE = PRICE * (1 + percentage / 100)
        WHERE FOODID = thisFood.FOODID;
        dbms_output.put_line(thisFood.FOODNAME || ' current price is '
            || thisFood.PRICE);
    END LOOP;
    CLOSE FoodCur;
END;


-- Finding the Loyal Customers who placed at least N orders
CREATE TABLE LoyalCustomers
(
    CUSTOMERID   NUMBER,
    ORDERS_COUNT NUMBER
);


CREATE OR REPLACE PROCEDURE find_customers_placed_at_least_n_orders(no_of_orders IN number)
AS
    CURSOR CustomerCur IS
        SELECT O.CUSTOMERID AS CID, COUNT(*) AS ORDERS_COUNT
        FROM CUSTOMER C, ORDERPICKUP O
        WHERE C.CUSTOMERID = O.CUSTOMERID
        GROUP BY O.CUSTOMERID;
    thisCustomer CustomerCur%ROWTYPE;
    orders_count number;
BEGIN
    DELETE FROM LoyalCustomers;
    OPEN CustomerCur;
    LOOP
        FETCH CustomerCur INTO thisCustomer;
        EXIT WHEN (CustomerCur%NOTFOUND);
        orders_count := thisCustomer.ORDERS_COUNT;
        IF orders_count >= no_of_orders THEN
            INSERT INTO LoyalCustomers
            VALUES (thisCustomer.CID, thisCustomer.ORDERS_COUNT);
            dbms_output.put_line(thisCustomer.CID || ' has placed '
                || thisCustomer.ORDERS_COUNT || ' orders');
        END IF;
    END LOOP;
    CLOSE CustomerCur;
END;

-- In case need to start over
DROP TRIGGER update_restaurant_rating;
DROP TRIGGER update_restaurant_rating_v2;
DROP TRIGGER update_fulfilled_orders;

DROP PROCEDURE increase_food_price_by_percent;
DROP TABLE LoyalCustomers;
DROP PROCEDURE find_customers_placed_at_least_n_orders; 