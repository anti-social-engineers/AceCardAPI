--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

-- Started on 2019-06-03 13:50:08

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
-- TOC entry 186 (class 1259 OID 72158)
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE addresses (
    id integer NOT NULL,
    address character varying(255) NOT NULL,
    address_num integer NOT NULL,
    address_annex character varying(1),
    city character varying(255) NOT NULL,
    postalcode character varying(6) NOT NULL,
    country character varying(5) NOT NULL
);


ALTER TABLE addresses OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 72156)
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE addresses_id_seq OWNER TO postgres;

--
-- TOC entry 2197 (class 0 OID 0)
-- Dependencies: 185
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- TOC entry 187 (class 1259 OID 72167)
-- Name: cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE cards (
    id uuid NOT NULL,
    card_code character varying(255) NOT NULL,
    is_activated boolean DEFAULT false NOT NULL,
    credits numeric(10,2) NOT NULL,
    is_blocked boolean DEFAULT false NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    activated_at timestamp with time zone,
    user_id_id uuid NOT NULL
);


ALTER TABLE cards OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 72172)
-- Name: clubs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE clubs (
    id uuid NOT NULL,
    min_age integer NOT NULL,
    club_name character varying(255) NOT NULL,
    club_address_id integer NOT NULL,
    owner_id uuid NOT NULL
);


ALTER TABLE clubs OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 72206)
-- Name: deposits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE deposits (
    id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    deposited_at timestamp with time zone NOT NULL,
    card_id_id uuid NOT NULL
);


ALTER TABLE deposits OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 72204)
-- Name: deposits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE deposits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE deposits_id_seq OWNER TO postgres;

--
-- TOC entry 2198 (class 0 OID 0)
-- Dependencies: 194
-- Name: deposits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE deposits_id_seq OWNED BY deposits.id;


--
-- TOC entry 193 (class 1259 OID 72198)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE payments (
    id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    paid_at timestamp with time zone NOT NULL,
    card_id_id uuid NOT NULL,
    club_id uuid NOT NULL
);


ALTER TABLE payments OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 72196)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE payments_id_seq OWNER TO postgres;

--
-- TOC entry 2199 (class 0 OID 0)
-- Dependencies: 192
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- TOC entry 191 (class 1259 OID 72187)
-- Name: penalties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE penalties (
    id integer NOT NULL,
    date_received date NOT NULL,
    description text NOT NULL,
    handed_out_by_id uuid,
    received_at_id uuid NOT NULL,
    recipient_id_id uuid NOT NULL
);


ALTER TABLE penalties OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 72185)
-- Name: penalties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE penalties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE penalties_id_seq OWNER TO postgres;

--
-- TOC entry 2200 (class 0 OID 0)
-- Dependencies: 190
-- Name: penalties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE penalties_id_seq OWNED BY penalties.id;


--
-- TOC entry 189 (class 1259 OID 72177)
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
    address_id integer
);


ALTER TABLE users OWNER TO postgres;

--
-- TOC entry 2034 (class 2604 OID 72161)
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- TOC entry 2037 (class 2604 OID 72209)
-- Name: deposits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits ALTER COLUMN id SET DEFAULT nextval('deposits_id_seq'::regclass);


--
-- TOC entry 2036 (class 2604 OID 72201)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- TOC entry 2035 (class 2604 OID 72190)
-- Name: penalties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties ALTER COLUMN id SET DEFAULT nextval('penalties_id_seq'::regclass);


--
-- TOC entry 2039 (class 2606 OID 72213)
-- Name: addresses addresses_address_address_num_city_18b2518a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_address_address_num_city_18b2518a_uniq UNIQUE (address, address_num, city, postalcode, country);


--
-- TOC entry 2041 (class 2606 OID 72166)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 2043 (class 2606 OID 72171)
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- TOC entry 2048 (class 2606 OID 72176)
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- TOC entry 2065 (class 2606 OID 72211)
-- Name: deposits deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits
    ADD CONSTRAINT deposits_pkey PRIMARY KEY (id);


--
-- TOC entry 2062 (class 2606 OID 72203)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 2056 (class 2606 OID 72195)
-- Name: penalties penalties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_pkey PRIMARY KEY (id);


--
-- TOC entry 2051 (class 2606 OID 72226)
-- Name: users users_first_name_last_name_date_of_birth_0ff19396_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_first_name_last_name_date_of_birth_0ff19396_uniq UNIQUE (first_name, last_name, date_of_birth);


--
-- TOC entry 2053 (class 2606 OID 72184)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2044 (class 1259 OID 72270)
-- Name: cards_user_id_id_9325af68; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_user_id_id_9325af68 ON cards USING btree (user_id_id);


--
-- TOC entry 2045 (class 1259 OID 72219)
-- Name: clubs_club_address_id_5d4314c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clubs_club_address_id_5d4314c9 ON clubs USING btree (club_address_id);


--
-- TOC entry 2046 (class 1259 OID 72264)
-- Name: clubs_owner_id_2db8d5b5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clubs_owner_id_2db8d5b5 ON clubs USING btree (owner_id);


--
-- TOC entry 2063 (class 1259 OID 72263)
-- Name: deposits_card_id_id_6d01cdd0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deposits_card_id_id_6d01cdd0 ON deposits USING btree (card_id_id);


--
-- TOC entry 2059 (class 1259 OID 72256)
-- Name: payments_card_id_id_e9ee5c9d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payments_card_id_id_e9ee5c9d ON payments USING btree (card_id_id);


--
-- TOC entry 2060 (class 1259 OID 72257)
-- Name: payments_club_id_6ab8b231; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payments_club_id_6ab8b231 ON payments USING btree (club_id);


--
-- TOC entry 2054 (class 1259 OID 72243)
-- Name: penalties_handed_out_by_id_11a76981; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX penalties_handed_out_by_id_11a76981 ON penalties USING btree (handed_out_by_id);


--
-- TOC entry 2057 (class 1259 OID 72244)
-- Name: penalties_received_at_id_41faf01e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX penalties_received_at_id_41faf01e ON penalties USING btree (received_at_id);


--
-- TOC entry 2058 (class 1259 OID 72245)
-- Name: penalties_recipient_id_id_dbab4a76; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX penalties_recipient_id_id_dbab4a76 ON penalties USING btree (recipient_id_id);


--
-- TOC entry 2049 (class 1259 OID 72227)
-- Name: users_address_id_96e92564; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_address_id_96e92564 ON users USING btree (address_id);


--
-- TOC entry 2066 (class 2606 OID 72271)
-- Name: cards cards_user_id_id_9325af68_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_user_id_id_9325af68_fk_users_id FOREIGN KEY (user_id_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2067 (class 2606 OID 72214)
-- Name: clubs clubs_club_address_id_5d4314c9_fk_addresses_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_club_address_id_5d4314c9_fk_addresses_id FOREIGN KEY (club_address_id) REFERENCES addresses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2068 (class 2606 OID 72265)
-- Name: clubs clubs_owner_id_2db8d5b5_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clubs
    ADD CONSTRAINT clubs_owner_id_2db8d5b5_fk_users_id FOREIGN KEY (owner_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2075 (class 2606 OID 72258)
-- Name: deposits deposits_card_id_id_6d01cdd0_fk_cards_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY deposits
    ADD CONSTRAINT deposits_card_id_id_6d01cdd0_fk_cards_id FOREIGN KEY (card_id_id) REFERENCES cards(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2073 (class 2606 OID 72246)
-- Name: payments payments_card_id_id_e9ee5c9d_fk_cards_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_card_id_id_e9ee5c9d_fk_cards_id FOREIGN KEY (card_id_id) REFERENCES cards(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2074 (class 2606 OID 72251)
-- Name: payments payments_club_id_6ab8b231_fk_clubs_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_club_id_6ab8b231_fk_clubs_id FOREIGN KEY (club_id) REFERENCES clubs(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2070 (class 2606 OID 72228)
-- Name: penalties penalties_handed_out_by_id_11a76981_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_handed_out_by_id_11a76981_fk_users_id FOREIGN KEY (handed_out_by_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2071 (class 2606 OID 72233)
-- Name: penalties penalties_received_at_id_41faf01e_fk_clubs_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_received_at_id_41faf01e_fk_clubs_id FOREIGN KEY (received_at_id) REFERENCES clubs(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2072 (class 2606 OID 72238)
-- Name: penalties penalties_recipient_id_id_dbab4a76_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalties
    ADD CONSTRAINT penalties_recipient_id_id_dbab4a76_fk_users_id FOREIGN KEY (recipient_id_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2069 (class 2606 OID 72220)
-- Name: users users_address_id_96e92564_fk_addresses_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_address_id_96e92564_fk_addresses_id FOREIGN KEY (address_id) REFERENCES addresses(id) DEFERRABLE INITIALLY DEFERRED;


-- Completed on 2019-06-03 13:50:08

--
-- PostgreSQL database dump complete
--

