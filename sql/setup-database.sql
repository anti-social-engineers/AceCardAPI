--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

-- Started on 2019-06-13 14:13:20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 73053)
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE addresses (
    id uuid NOT NULL,
    address character varying(255) NOT NULL,
    address_num integer NOT NULL,
    address_annex character varying(1),
    city character varying(255) NOT NULL,
    postalcode character varying(6) NOT NULL,
    country character varying(5) NOT NULL
);


ALTER TABLE addresses OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 73061)
-- Name: cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE cards (
    id uuid NOT NULL,
    card_code character varying(255),
    is_activated boolean DEFAULT false NOT NULL,
    credits numeric(10,2) DEFAULT 0 NOT NULL,
    is_blocked boolean DEFAULT false NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    activated_at timestamp with time zone,
    pin character varying(255),
    pin_salt character varying(255),
    user_id_id uuid NOT NULL
);


ALTER TABLE cards OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 73071)
-- Name: clubs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE clubs (
    id uuid NOT NULL,
    min_age integer NOT NULL,
    club_name character varying(255) NOT NULL,
    club_address_id uuid NOT NULL,
    owner_id uuid NOT NULL
);


ALTER TABLE clubs OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 73099)
-- Name: deposits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE deposits (
    id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    deposited_at timestamp with time zone NOT NULL,
    source_id character varying(28),
    charge_id character varying(28),
    status character varying(16) DEFAULT 'source_waiting' NOT NULL,
    card_id_id uuid NOT NULL
);


ALTER TABLE deposits OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 73094)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE payments (
    id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    paid_at timestamp with time zone NOT NULL,
    card_id_id uuid NOT NULL,
    club_id uuid NOT NULL
);


ALTER TABLE payments OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 73086)
-- Name: penalties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE penalties (
    id uuid NOT NULL,
    date_received date NOT NULL,
    description text NOT NULL,
    handed_out_by_id uuid,
    received_at_id uuid NOT NULL,
    recipient_id_id uuid NOT NULL
);


ALTER TABLE penalties OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 73076)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE users (
    id uuid NOT NULL,
    email character varying(254) NOT NULL,
    password character varying(255) NOT NULL,
    password_salt character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    gender character varying(15),
    date_of_birth date,
    is_email_verified boolean DEFAULT false NOT NULL,
    role character varying(15) DEFAULT 'user' NOT NULL,
    image_id uuid,
    address_id uuid
);


ALTER TABLE users OWNER TO postgres;

--
-- TOC entry 2028 (class 2606 OID 73109)
-- Name: addresses addresses_address_address_num_city_18b2518a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_address_address_num_city_18b2518a_uniq UNIQUE (address, address_num, city, postalcode, country);


--
-- TOC entry 2030 (class 2606 OID 73060)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 2033 (class 2606 OID 73070)
-- Name: cards cards_card_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_card_code_key UNIQUE (card_code);


--
-- TOC entry 2035 (class 2606 OID 73068)
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- TOC entry 2040 (class 2606 OID 73075)
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- TOC entry 2059 (class 2606 OID 73107)
-- Name: deposits deposits_charge_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits
    ADD CONSTRAINT deposits_charge_id_key UNIQUE (charge_id);


--
-- TOC entry 2061 (class 2606 OID 73103)
-- Name: deposits deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits
    ADD CONSTRAINT deposits_pkey PRIMARY KEY (id);


--
-- TOC entry 2064 (class 2606 OID 73105)
-- Name: deposits deposits_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits
    ADD CONSTRAINT deposits_source_id_key UNIQUE (source_id);


--
-- TOC entry 2055 (class 2606 OID 73098)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 2049 (class 2606 OID 73093)
-- Name: penalties penalties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_pkey PRIMARY KEY (id);


--
-- TOC entry 2044 (class 2606 OID 73085)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 2046 (class 2606 OID 73083)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2031 (class 1259 OID 73110)
-- Name: cards_card_code_5bdcceef_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_card_code_5bdcceef_like ON cards USING btree (card_code varchar_pattern_ops);


--
-- TOC entry 2036 (class 1259 OID 73168)
-- Name: cards_user_id_id_9325af68; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_user_id_id_9325af68 ON cards USING btree (user_id_id);


--
-- TOC entry 2037 (class 1259 OID 73116)
-- Name: clubs_club_address_id_5d4314c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clubs_club_address_id_5d4314c9 ON clubs USING btree (club_address_id);


--
-- TOC entry 2038 (class 1259 OID 73162)
-- Name: clubs_owner_id_2db8d5b5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clubs_owner_id_2db8d5b5 ON clubs USING btree (owner_id);


--
-- TOC entry 2056 (class 1259 OID 73161)
-- Name: deposits_card_id_id_6d01cdd0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deposits_card_id_id_6d01cdd0 ON deposits USING btree (card_id_id);


--
-- TOC entry 2057 (class 1259 OID 73160)
-- Name: deposits_charge_id_77bf83f1_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deposits_charge_id_77bf83f1_like ON deposits USING btree (charge_id varchar_pattern_ops);


--
-- TOC entry 2062 (class 1259 OID 73159)
-- Name: deposits_source_id_4f571b7e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deposits_source_id_4f571b7e_like ON deposits USING btree (source_id varchar_pattern_ops);


--
-- TOC entry 2052 (class 1259 OID 73152)
-- Name: payments_card_id_id_e9ee5c9d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payments_card_id_id_e9ee5c9d ON payments USING btree (card_id_id);


--
-- TOC entry 2053 (class 1259 OID 73153)
-- Name: payments_club_id_6ab8b231; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payments_club_id_6ab8b231 ON payments USING btree (club_id);


--
-- TOC entry 2047 (class 1259 OID 73139)
-- Name: penalties_handed_out_by_id_11a76981; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX penalties_handed_out_by_id_11a76981 ON penalties USING btree (handed_out_by_id);


--
-- TOC entry 2050 (class 1259 OID 73140)
-- Name: penalties_received_at_id_41faf01e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX penalties_received_at_id_41faf01e ON penalties USING btree (received_at_id);


--
-- TOC entry 2051 (class 1259 OID 73141)
-- Name: penalties_recipient_id_id_dbab4a76; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX penalties_recipient_id_id_dbab4a76 ON penalties USING btree (recipient_id_id);


--
-- TOC entry 2041 (class 1259 OID 73123)
-- Name: users_address_id_96e92564; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_address_id_96e92564 ON users USING btree (address_id);


--
-- TOC entry 2042 (class 1259 OID 73122)
-- Name: users_email_0ea73cca_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_email_0ea73cca_like ON users USING btree (email varchar_pattern_ops);


--
-- TOC entry 2065 (class 2606 OID 73169)
-- Name: cards cards_user_id_id_9325af68_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_user_id_id_9325af68_fk_users_id FOREIGN KEY (user_id_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2066 (class 2606 OID 73111)
-- Name: clubs clubs_club_address_id_5d4314c9_fk_addresses_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_club_address_id_5d4314c9_fk_addresses_id FOREIGN KEY (club_address_id) REFERENCES addresses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2067 (class 2606 OID 73163)
-- Name: clubs clubs_owner_id_2db8d5b5_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_owner_id_2db8d5b5_fk_users_id FOREIGN KEY (owner_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2074 (class 2606 OID 73154)
-- Name: deposits deposits_card_id_id_6d01cdd0_fk_cards_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits
    ADD CONSTRAINT deposits_card_id_id_6d01cdd0_fk_cards_id FOREIGN KEY (card_id_id) REFERENCES cards(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2072 (class 2606 OID 73142)
-- Name: payments payments_card_id_id_e9ee5c9d_fk_cards_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_card_id_id_e9ee5c9d_fk_cards_id FOREIGN KEY (card_id_id) REFERENCES cards(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2073 (class 2606 OID 73147)
-- Name: payments payments_club_id_6ab8b231_fk_clubs_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_club_id_6ab8b231_fk_clubs_id FOREIGN KEY (club_id) REFERENCES clubs(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2069 (class 2606 OID 73124)
-- Name: penalties penalties_handed_out_by_id_11a76981_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_handed_out_by_id_11a76981_fk_users_id FOREIGN KEY (handed_out_by_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2070 (class 2606 OID 73129)
-- Name: penalties penalties_received_at_id_41faf01e_fk_clubs_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_received_at_id_41faf01e_fk_clubs_id FOREIGN KEY (received_at_id) REFERENCES clubs(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2071 (class 2606 OID 73134)
-- Name: penalties penalties_recipient_id_id_dbab4a76_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_recipient_id_id_dbab4a76_fk_users_id FOREIGN KEY (recipient_id_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2068 (class 2606 OID 73117)
-- Name: users users_address_id_96e92564_fk_addresses_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_address_id_96e92564_fk_addresses_id FOREIGN KEY (address_id) REFERENCES addresses(id) DEFERRABLE INITIALLY DEFERRED;


-- Completed on 2019-06-13 14:13:20

--
-- PostgreSQL database dump complete
--

